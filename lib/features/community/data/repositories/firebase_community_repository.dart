import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_labels.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../domain/entities/community_entities.dart';
import '../../domain/repositories/community_repository.dart';
import '../models/community_documents.dart';

/// Cộng đồng đọc từ Firestore: bài đăng, bảng xếp hạng, nhóm học tập.
class FirebaseCommunityRepository implements CommunityRepository {
  const FirebaseCommunityRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  /// Số người hiện trên bảng xếp hạng.
  static const _leaderboardSize = 20;

  String _requireUid() {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();
    return user.id;
  }

  @override
  Future<Leaderboard> getLeaderboard() async {
    final uid = _requireUid();

    try {
      final snapshot = await _firestore
          .collection(UserDocument.collection)
          .orderBy('experience', descending: true)
          .limit(_leaderboardSize)
          .get();

      final entries = <LeaderboardEntry>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final name = data['name'];
        entries.add(
          LeaderboardEntry(
            rank: i + 1,
            name: name is String && name.isNotEmpty ? name : 'Người học',
            // Rỗng = chưa có ảnh tự đặt; `RankAvatar` sẽ dùng huy hiệu
            // hạng suy từ XP. Trước đây gán cứng một sticker nên cả bảng xếp
            // hạng ai cũng cùng một mặt.
            avatarAsset: '',
            experience: switch (data['experience']) {
              final num value => value.toInt(),
              _ => 0,
            },
            isCurrentUser: doc.id == uid,
          ),
        );
      }

      // Hạng giải đấu suy từ XP của chính mình, không lưu riêng để hai chỗ khỏi
      // lệch nhau.
      final myExperience = entries
          .where((entry) => entry.isCurrentUser)
          .map((entry) => entry.experience)
          .firstOrNull;

      return Leaderboard(
        currentRank: ForestRank.fromExperience(myExperience ?? 0),
        entries: entries,
        // Nửa trên bảng là vùng an toàn.
        safeZoneEndRank: (entries.length / 2).ceil(),
      );
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  /// Truy van moi thanh vien cua mot nhom.
  ///
  /// Thanh vien **chinh la** `users/{uid}.groupId`, khong co subcollection
  /// rieng: vao/roi nhom chi can ghi document cua chinh minh, nen khong phai mo
  /// quyen ghi vao document nhom cho moi nguoi.
  Query<Map<String, dynamic>> _membersOf(String groupId) => _firestore
      .collection(UserDocument.collection)
      .where('groupId', isEqualTo: groupId);

  @override
  Future<StudyGroup?> getStudyGroup() async {
    final uid = _requireUid();

    try {
      final userSnapshot = await _firestore
          .collection(UserDocument.collection)
          .doc(uid)
          .get();
      final groupId = userSnapshot.data()?['groupId'];
      if (groupId is! String || groupId.isEmpty) return null;

      final groupRef = _firestore
          .collection(GroupDocument.collection)
          .doc(groupId);

      // So thanh vien va XP nhom tinh bang aggregate ngay tren server: khong
      // tai toan bo ho so ve may, va khong co con so luu san de lech.
      // Khoi tao truoc roi await tung cai: van chay song song vi future trong
      // Dart la eager. Khong dung `(f1, f2).wait` — no goi loi vao
      // ParallelWaitError nen `on FirebaseException` ben duoi se truot.
      final groupSnapshotFuture = groupRef.get();
      final statsFuture = _membersOf(
        groupId,
      ).aggregate(count(), sum('experience')).get();
      final groupSnapshot = await groupSnapshotFuture;
      final stats = await statsFuture;

      final data = groupSnapshot.data();
      if (data == null) return null;

      return GroupDocument.toEntity(
        groupId,
        data,
        memberCount: stats.count ?? 0,
        totalExperience: (stats.getSum('experience') ?? 0).toInt(),
        isLeader: data['leaderId'] == uid,
      );
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<List<StudyGroupSummary>> getJoinableGroups() async {
    _requireUid();

    try {
      final snapshot = await _firestore
          .collection(GroupDocument.collection)
          .limit(30)
          .get();

      final counts = await Future.wait(
        snapshot.docs.map((doc) => _membersOf(doc.id).count().get()),
      );

      return [
        for (var i = 0; i < snapshot.docs.length; i++)
          StudyGroupSummary(
            id: snapshot.docs[i].id,
            name: readDocString(
              snapshot.docs[i].data()['name'],
              fallback: snapshot.docs[i].id,
            ),
            leaderName: readDocString(
              snapshot.docs[i].data()['leaderName'],
              fallback: 'Chua ro',
            ),
            memberCount: counts[i].count ?? 0,
          ),
      ];
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> createGroup(String name) async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Ten nhom khong duoc de trong.');
    }

    try {
      final groupRef = _firestore.collection(GroupDocument.collection).doc();

      final batch = _firestore.batch();
      batch.set(groupRef, {
        'name': trimmed,
        // `leaderId` phai la uid cua minh: rules chan viec tao nhom roi gan
        // truong nhom cho nguoi khac.
        'leaderId': user.id,
        'leaderName': user.greetingName,
        'daysRemaining': GroupDocument.defaultSeasonDays,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(
        _firestore.collection(UserDocument.collection).doc(user.id),
        {'groupId': groupRef.id, 'groupName': trimmed},
        SetOptions(merge: true),
      );
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> joinGroup(String groupId) async {
    final uid = _requireUid();

    try {
      final groupSnapshot = await _firestore
          .collection(GroupDocument.collection)
          .doc(groupId)
          .get();
      final data = groupSnapshot.data();
      if (data == null) {
        throw const NotFoundFailure('Nhom nay khong con ton tai.');
      }

      await _firestore.collection(UserDocument.collection).doc(uid).set({
        'groupId': groupId,
        'groupName': readDocString(data['name'], fallback: groupId),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> leaveGroup() async {
    final uid = _requireUid();

    try {
      // Xoa field thay vi ghi chuoi rong, de truy van where('groupId', ==)
      // khong bao gio khop document nay nua.
      await _firestore.collection(UserDocument.collection).doc(uid).update({
        'groupId': FieldValue.delete(),
        'groupName': FieldValue.delete(),
      });
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  // --- Chat nhom & binh luan -------------------------------------------

  @override
  Stream<List<ChatMessage>> watchGroupMessages(String groupId) =>
      _watchMessages(_groupMessages(groupId));

  @override
  Future<void> sendGroupMessage(
    String groupId, {
    String? text,
    String? stickerAsset,
  }) => _sendMessage(
    _groupMessages(groupId),
    text: text,
    stickerAsset: stickerAsset,
  );

  CollectionReference<Map<String, dynamic>> _groupMessages(String groupId) =>
      _firestore
          .collection(GroupDocument.collection)
          .doc(groupId)
          .collection(GroupDocument.messagesCollection);

  Stream<List<ChatMessage>> _watchMessages(
    CollectionReference<Map<String, dynamic>> collection,
  ) {
    final uid = _authRepository.currentUser?.id ?? '';
    return collection
        .orderBy('createdAt')
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageDocument.toEntity(
                  doc.id,
                  doc.data(),
                  currentUid: uid,
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> _sendMessage(
    CollectionReference<Map<String, dynamic>> collection, {
    String? text,
    String? stickerAsset,
    void Function(WriteBatch batch)? alsoWrite,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    final hasText = text != null && text.trim().isNotEmpty;
    final hasSticker = stickerAsset != null && stickerAsset.isNotEmpty;
    if (!hasText && !hasSticker) {
      throw const ValidationFailure('Chua co noi dung de gui.');
    }

    try {
      final batch = _firestore.batch();
      batch.set(
        collection.doc(),
        MessageDocument.toMap(
          authorId: user.id,
          authorName: user.greetingName,
          text: text,
          stickerAsset: stickerAsset,
        ),
      );
      alsoWrite?.call(batch);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền truy cập dữ liệu cộng đồng.',
      ),
      'unavailable' => const NetworkFailure(),
      'failed-precondition' => const ServerFailure(
        'Firestore cần tạo index cho truy vấn này. '
        'Xem link trong log để tạo bằng một cú bấm.',
      ),
      _ => ServerFailure(error.message ?? 'Không tải được dữ liệu cộng đồng.'),
    };
  }
}
