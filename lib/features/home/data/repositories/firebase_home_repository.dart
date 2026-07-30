import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../../quiz/data/models/topic_document.dart';
import '../../../vocabulary/data/models/vocabulary_document.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';

/// Dữ liệu trang chủ tổng hợp từ Firestore.
class FirebaseHomeRepository implements HomeRepository {
  const FirebaseHomeRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  /// Mục tiêu học mỗi ngày.
  static const dailyLearnGoal = 5;

  /// Mục tiêu ôn mỗi ngày.
  static const dailyReviewGoal = 10;

  @override
  Future<HomeSummary> getSummary() async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    final uid = user.id;
    final today = UserDocument.dateKey(DateTime.now());
    final userRef = _firestore.collection(UserDocument.collection).doc(uid);

    try {
      // Bốn truy vấn song song: người dùng chờ theo truy vấn chậm nhất chứ
      // không phải tổng thời gian cả bốn.
      final (
        userSnapshot,
        statsSnapshot,
        progressCount,
        topicsSnapshot,
      ) = await (
        userRef.get(),
        userRef.collection(UserDocument.dailyStatsCollection).doc(today).get(),
        userRef.collection(WordProgressDocument.collection).count().get(),
        _firestore.collection(TopicDocument.collection).get(),
      ).wait;

      final userData = userSnapshot.data() ?? const <String, dynamic>{};
      final statsData = statsSnapshot.data() ?? const <String, dynamic>{};

      final learnedToday = _readInt(statsData['wordsLearned']);
      final reviewedToday = _readInt(statsData['wordsReviewed']);
      final totalLearned = progressCount.count ?? 0;
      final totalWords = topicsSnapshot.docs.fold<int>(
        0,
        (total, doc) => total + _readInt(doc.data()['wordCount']),
      );

      return HomeSummary(
        userName: user.greetingName,
        streakDays: _readInt(userData['streakDays']),
        gemCount: _readInt(userData['gems']),
        seedCount: _readInt(userData['seeds']),
        learnGoal: DailyGoal(
          title: 'Học từ mới',
          completed: learnedToday,
          target: dailyLearnGoal,
        ),
        reviewGoal: DailyGoal(
          title: 'Ôn tập ngay',
          completed: reviewedToday,
          target: dailyReviewGoal,
        ),
        monthlyQuest: QuestGroup(
          title: 'Hành trình từ vựng',
          quests: [
            Quest(
              title: 'Học hết $totalWords từ trong giáo trình',
              completed: totalLearned,
              target: totalWords,
            ),
          ],
        ),
        dailyQuests: QuestGroup(
          title: 'Nhiệm vụ hằng ngày',
          quests: [
            Quest(
              title: 'Học $dailyLearnGoal từ mới',
              completed: learnedToday,
              target: dailyLearnGoal,
            ),
            Quest(
              title: 'Ôn tập $dailyReviewGoal từ',
              completed: reviewedToday,
              target: dailyReviewGoal,
            ),
            Quest(
              title: 'Trả lời đúng 10 câu',
              completed: _readInt(statsData['correctAnswers']),
              target: 10,
            ),
          ],
        ),
      );
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  static int _readInt(Object? value) => value is num ? value.toInt() : 0;

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền đọc dữ liệu trang chủ.',
      ),
      'unavailable' => const NetworkFailure(),
      _ => ServerFailure(error.message ?? 'Không tải được trang chủ.'),
    };
  }
}
