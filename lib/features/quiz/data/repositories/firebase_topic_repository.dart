import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../domain/entities/vocabulary_topic.dart';
import '../../domain/repositories/topic_repository.dart';
import '../models/topic_document.dart';

/// Danh sách chủ đề đọc từ Firestore.
///
/// Ghép hai nguồn: `topics` (dùng chung, chỉ đọc) và
/// `users/{uid}/topicProgress` (tiến độ riêng của người dùng).
class FirebaseTopicRepository implements TopicRepository {
  const FirebaseTopicRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  @override
  Future<List<VocabularyTopic>> getTopics() async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    try {
      // Hai truy vấn chạy song song thay vì nối tiếp: người dùng chờ theo truy
      // vấn chậm nhất chứ không phải tổng thời gian cả hai.
      final (topicsSnapshot, progressSnapshot) = await (
        _firestore.collection(TopicDocument.collection).orderBy('order').get(),
        _firestore
            .collection(UserDocument.collection)
            .doc(user.id)
            .collection(TopicDocument.progressCollection)
            .get(),
      ).wait;

      final learnedByTopic = <String, int>{
        for (final doc in progressSnapshot.docs)
          doc.id: switch (doc.data()['learnedCount']) {
            final num value => value.toInt(),
            _ => 0,
          },
      };

      return topicsSnapshot.docs
          .map(
            (doc) => TopicDocument.fromMap(
              doc.id,
              doc.data(),
            ).toEntity(learnedCount: learnedByTopic[doc.id] ?? 0),
          )
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền đọc danh sách chủ đề.',
      ),
      'unavailable' => const NetworkFailure(),
      _ => ServerFailure(error.message ?? 'Không tải được danh sách chủ đề.'),
    };
  }
}
