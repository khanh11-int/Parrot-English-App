import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../domain/entities/shop_item.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_item_document.dart';

/// Cửa hàng đọc từ Firestore.
///
/// Ghép ba nguồn: `shopItems` (dùng chung), `users/{uid}` (ví) và
/// `users/{uid}/inventory` (vật phẩm đang có).
class FirebaseShopRepository implements ShopRepository {
  const FirebaseShopRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection(UserDocument.collection).doc(uid);

  CollectionReference<Map<String, dynamic>> _inventory(String uid) =>
      _userDoc(uid).collection(ShopItemDocument.inventoryCollection);

  String _requireUid() {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();
    return user.id;
  }

  @override
  Future<ShopData> getShopData() async {
    final uid = _requireUid();

    try {
      final (itemsSnapshot, userSnapshot, inventorySnapshot) = await (
        _firestore
            .collection(ShopItemDocument.collection)
            .orderBy('order')
            .get(),
        _userDoc(uid).get(),
        _inventory(uid).get(),
      ).wait;

      final ownedByItem = <String, int>{
        for (final doc in inventorySnapshot.docs)
          doc.id: _readInt(doc.data()['count']),
      };

      final userData = userSnapshot.data() ?? const <String, dynamic>{};

      return ShopData(
        wallet: Wallet(
          seeds: _readInt(userData['seeds']),
          gems: _readInt(userData['gems']),
        ),
        items: itemsSnapshot.docs
            .map(
              (doc) => ShopItemDocument.fromMap(
                doc.id,
                doc.data(),
              ).toEntity(ownedCount: ownedByItem[doc.id] ?? 0),
            )
            .toList(growable: false),
      );
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<ShopData> purchase(String itemId) async {
    final uid = _requireUid();

    try {
      final itemSnapshot = await _firestore
          .collection(ShopItemDocument.collection)
          .doc(itemId)
          .get();
      final itemData = itemSnapshot.data();
      if (itemData == null) {
        throw const NotFoundFailure('Vật phẩm không còn trong cửa hàng.');
      }
      final item = ShopItemDocument.fromMap(itemId, itemData);

      // Dùng transaction để trừ tiền và cộng vật phẩm là một khối không thể
      // tách. Nếu chỉ đọc rồi ghi, hai lần mua gần nhau trên hai thiết bị sẽ
      // cùng đọc số dư cũ và trừ tiền một lần.
      await _firestore.runTransaction((transaction) async {
        final userDoc = _userDoc(uid);
        final userSnapshot = await transaction.get(userDoc);
        final userData = userSnapshot.data() ?? const <String, dynamic>{};

        final field = item.currency == ShopCurrency.gem ? 'gems' : 'seeds';
        final balance = _readInt(userData[field]);
        if (balance < item.price) {
          final currencyName = item.currency == ShopCurrency.gem
              ? 'ngọc'
              : 'hạt';
          throw ValidationFailure(
            'Không đủ $currencyName để mua ${item.name}.',
          );
        }

        transaction.update(userDoc, {field: balance - item.price});
        transaction.set(_inventory(uid).doc(itemId), {
          'count': FieldValue.increment(1),
        }, SetOptions(merge: true));
      });

      // Đọc lại để UI hiển thị đúng số dư server đã ghi, không phải số client
      // tự tính.
      return getShopData();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  static int _readInt(Object? value) => value is num ? value.toInt() : 0;

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền thực hiện thao tác này.',
      ),
      'unavailable' => const NetworkFailure(),
      'not-found' => const NotFoundFailure(),
      _ => ServerFailure(error.message ?? 'Không tải được cửa hàng.'),
    };
  }
}
