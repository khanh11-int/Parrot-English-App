import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_document.dart';

/// Hồ sơ người dùng đọc từ Firestore `users/{uid}`.
class FirebaseProfileRepository implements ProfileRepository {
  const FirebaseProfileRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  DocumentReference<Map<String, dynamic>> _docFor(String uid) =>
      _firestore.collection(UserDocument.collection).doc(uid);

  @override
  Future<UserProfile> getProfile() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw const UnauthorizedFailure();
    }

    try {
      final snapshot = await _docFor(user.id).get();
      final data = snapshot.data();
      if (data == null) {
        // Hồ sơ chưa có (tài khoản tạo trước khi có bước tạo hồ sơ, hoặc lần
        // ghi đầu thất bại) → tạo rồi trả bản mặc định, không để trang lỗi.
        await createProfileIfMissing(user);
        return UserDocument.initialFor(user).toEntity();
      }
      return UserDocument.fromMap(data).toEntity();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> createProfileIfMissing(AppUser user) async {
    try {
      final doc = _docFor(user.id);
      final snapshot = await doc.get();
      if (snapshot.exists) return;

      await doc.set(UserDocument.initialFor(user).toMap());
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền truy cập dữ liệu này.',
      ),
      'unavailable' => const NetworkFailure(),
      'not-found' => const NotFoundFailure(),
      _ => ServerFailure(error.message ?? 'Không đọc được dữ liệu.'),
    };
  }
}
