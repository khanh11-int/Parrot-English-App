import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../../quiz/data/models/topic_document.dart';
import '../../../vocabulary/data/models/vocabulary_document.dart';
import '../../domain/entities/review_deck.dart';
import '../../domain/repositories/review_repository.dart';

/// Danh sách bộ từ cần ôn, ghép từ giáo trình và tiến độ của người dùng.
class FirebaseReviewRepository implements ReviewRepository {
  const FirebaseReviewRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  @override
  Future<List<ReviewDeck>> getDecks() async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    try {
      final (topicsSnapshot, progressSnapshot) = await (
        _firestore.collection(TopicDocument.collection).orderBy('order').get(),
        _firestore
            .collection(UserDocument.collection)
            .doc(user.id)
            .collection(WordProgressDocument.collection)
            .get(),
      ).wait;

      // Nhóm tiến độ theo chủ đề trong một lượt, thay vì truy vấn lại cho từng
      // chủ đề — 7 chủ đề sẽ là 7 lượt gọi mạng không cần thiết.
      final now = DateTime.now();
      final learnedPerTopic = <String, int>{};
      final masteredPerTopic = <String, int>{};
      final duePerTopic = <String, int>{};

      for (final doc in progressSnapshot.docs) {
        final progress = WordProgressDocument.toEntity(doc.id, doc.data());
        final topicId = progress.topicId;
        if (topicId.isEmpty) continue;

        learnedPerTopic[topicId] = (learnedPerTopic[topicId] ?? 0) + 1;
        if (progress.isMastered) {
          masteredPerTopic[topicId] = (masteredPerTopic[topicId] ?? 0) + 1;
        }
        if (progress.isDue(now)) {
          duePerTopic[topicId] = (duePerTopic[topicId] ?? 0) + 1;
        }
      }

      // Hiện mọi chủ đề, kể cả chưa học từ nào: người dùng thấy được còn bao
      // nhiêu chủ đề chưa chạm tới.
      return topicsSnapshot.docs
          .map((doc) {
            final topic = TopicDocument.fromMap(doc.id, doc.data());
            return ReviewDeck(
              topic: topic.name,
              totalCount: topic.wordCount,
              // "Đã thuộc" là từ có khoảng lặp lại đủ dài, không phải mọi từ đã
              // gặp — tính cả từ mới học thì thanh tiến độ sẽ đầy một cách giả.
              masteredCount: masteredPerTopic[doc.id] ?? 0,
              dueCount: duePerTopic[doc.id] ?? 0,
            );
          })
          .toList(growable: false);
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền đọc bộ từ ôn tập.',
      ),
      'unavailable' => const NetworkFailure(),
      _ => ServerFailure(error.message ?? 'Không tải được bộ từ ôn tập.'),
    };
  }
}
