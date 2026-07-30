import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../domain/entities/saved_word.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../models/vocabulary_document.dart';

/// Bộ từ người dùng lưu từ ảnh chụp, ở `users/{uid}/savedWords`.
///
/// Cố ý **không** đụng tới `wordProgress` hay `topicProgress`: đây là danh sách
/// để xem lại, không phải giáo trình, nên lưu bao nhiêu từ cũng không làm tiến
/// độ học nhảy lên.
class FirebaseSavedWordRepository implements SavedWordRepository {
  const FirebaseSavedWordRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  String _requireUid() {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();
    return user.id;
  }

  CollectionReference<Map<String, dynamic>> _saved(String uid) => _firestore
      .collection(UserDocument.collection)
      .doc(uid)
      .collection(SavedWordDocument.collection);

  @override
  Future<void> saveWords(List<SavedWord> words) async {
    if (words.isEmpty) return;
    final uid = _requireUid();

    try {
      final batch = _firestore.batch();
      for (final word in words) {
        // `merge` để chụp trùng một vật chỉ cập nhật, không tạo bản trùng.
        batch.set(
          _saved(uid).doc(word.id),
          SavedWordDocument.toMap(word),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<List<SavedWord>> getSavedWords({int limit = 100}) async {
    final uid = _requireUid();

    try {
      final snapshot = await _saved(
        uid,
      ).orderBy('savedAt', descending: true).limit(limit).get();
      return snapshot.docs
          .map((doc) => SavedWordDocument.toEntity(doc.id, doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> removeWord(String wordId) async {
    final uid = _requireUid();
    try {
      await _saved(uid).doc(wordId).delete();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền truy cập bộ từ đã lưu.',
      ),
      'unavailable' => const NetworkFailure(),
      _ => ServerFailure(error.message ?? 'Không truy cập được bộ từ đã lưu.'),
    };
  }
}
