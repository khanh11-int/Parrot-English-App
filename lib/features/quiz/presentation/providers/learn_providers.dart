import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_rewards.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/providers/user_data_revision.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../vocabulary/domain/entities/topic_word.dart';
import '../../../vocabulary/presentation/providers/vocabulary_providers.dart';
import '../../data/repositories/firebase_learn_repository.dart';
import '../../data/repositories/firebase_topic_repository.dart';
import '../../domain/entities/learn_question.dart';
import '../../domain/entities/vocabulary_topic.dart';
import '../../domain/repositories/learn_repository.dart';
import '../../domain/repositories/topic_repository.dart';

/// Sinh phiên học từ các từ người dùng đã lưu trong Firestore.
///
/// Test override provider này bằng `LearnMockRepository`.
final learnRepositoryProvider = Provider<LearnRepository>((ref) {
  return FirebaseLearnRepository(ref.watch(vocabularyRepositoryProvider));
});

/// Danh mục chủ đề đọc từ Firestore.
///
/// Test override provider này bằng `TopicMockRepository`.
final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return FirebaseTopicRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

/// Danh sách chủ đề kèm tiến độ, dùng cho trang chọn chủ đề để học.
final learnTopicsProvider = FutureProvider<List<VocabularyTopic>>((ref) {
  // Đổi người đăng nhập thì tải lại: tiến độ là của riêng từng người.
  ref.watch(currentUserProvider);
  // Học xong là vòng tiến độ của chủ đề vừa học phải nhích lên ngay.
  ref.watch(userDataRevisionProvider);
  return ref.watch(topicRepositoryProvider).getTopics();
});

/// Loại phiên: học từ mới hay ôn tập. Hai luồng dùng chung toàn bộ widget bài
/// tập, chỉ khác nguồn từ.
enum SessionMode { learn, review }

/// Khoá của một phiên: loại phiên + chủ đề (chủ đề `null` = học trộn mọi chủ đề
/// hoặc phiên ôn tập).
///
/// Dùng record làm khoá family vì record so sánh theo giá trị, nên hai lần vào
/// cùng một chủ đề sẽ dùng lại đúng một phiên.
typedef SessionKey = ({SessionMode mode, String? topicId});

/// Tiến trình của một phiên học/ôn tập.
class SessionProgress {
  const SessionProgress({
    required this.session,
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
  });

  final LearnSession session;

  /// Chỉ số vòng đang làm.
  final int currentIndex;
  final int correctCount;
  final int wrongCount;

  Exercise get currentExercise => session.exercises[currentIndex];

  int get totalRounds => session.exercises.length;

  /// Số vòng hiển thị cho người học, đếm từ 1.
  int get currentRound => currentIndex + 1;

  bool get isFinished => currentIndex >= session.exercises.length;

  double get progress =>
      totalRounds == 0 ? 0 : (currentIndex / totalRounds).clamp(0.0, 1.0);

  SessionProgress copyWith({
    int? currentIndex,
    int? correctCount,
    int? wrongCount,
  }) {
    return SessionProgress(
      session: session,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
    );
  }

  /// Quy đổi kết quả thành XP và hạt.
  SessionResult toResult() {
    return SessionResult(
      learnedWordCount: totalRounds,
      correctCount: correctCount,
      wrongCount: wrongCount,
      earnedExperience: correctCount * AppRewards.experiencePerCorrectAnswer,
      earnedSeeds: correctCount * AppRewards.seedsPerCorrectAnswer,
    );
  }
}

/// Điều khiển một phiên học: chuyển vòng, đếm đúng/sai, gửi kết quả lên server.
class SessionController
    extends FamilyAsyncNotifier<SessionProgress, SessionKey> {
  @override
  Future<SessionProgress> build(SessionKey key) async {
    final repository = ref.read(learnRepositoryProvider);
    final session = switch (key.mode) {
      SessionMode.learn => await repository.getLearnSession(
        topicId: key.topicId,
      ),
      SessionMode.review => await repository.getReviewSession(
        topicId: key.topicId,
      ),
    };
    return SessionProgress(session: session);
  }

  /// Ghi nhận kết quả một vòng rồi sang vòng tiếp theo.
  void completeRound({required bool isCorrect}) {
    final current = state.valueOrNull;
    if (current == null || current.isFinished) return;

    // Phải đọc bài tập TRƯỚC khi tăng chỉ số vòng, nếu không sẽ ghi lịch ôn cho
    // vòng kế tiếp thay vì vòng vừa làm. Cố ý không `await`: ghi chạy nền.
    unawaited(_recordReviews(current.currentExercise, isCorrect: isCorrect));

    final updated = current.copyWith(
      currentIndex: current.currentIndex + 1,
      correctCount: current.correctCount + (isCorrect ? 1 : 0),
      wrongCount: current.wrongCount + (isCorrect ? 0 : 1),
    );
    state = AsyncData(updated);

    if (updated.isFinished) _submitResult(updated);
  }

  /// Ghi nhận một câu trả lời sai giữa vòng (ví dụ ghép sai một cặp) mà chưa
  /// chuyển vòng.
  void recordWrongAnswer() {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(wrongCount: current.wrongCount + 1));
  }

  /// Ghi tiến độ SRS cho các từ vừa xuất hiện trong vòng.
  ///
  /// Ghi ngay từng vòng thay vì đợi hết phiên: người học thoát giữa phiên vẫn
  /// giữ được tiến độ những vòng đã làm.
  ///
  /// Không `await` ở [completeRound]: người học được sang vòng sau ngay, không
  /// phải chờ mạng.
  Future<void> _recordReviews(
    Exercise exercise, {
    required bool isCorrect,
  }) async {
    final progress = state.valueOrNull;
    if (progress == null) return;

    final pairs = switch (exercise) {
      final MatchPairsExerciseData data => data.pairs,
      final MultipleChoiceExerciseData data => [data.word],
    };

    // `arg` là khoá family mà provider được tạo với — chính là (mode, topicId).
    final topicId = arg.topicId;
    final repository = ref.read(vocabularyRepositoryProvider);
    await Future.wait([
      for (final pair in pairs)
        repository
            .recordAnswer(
              word: TopicWord(
                id: pair.id,
                // Phiên ôn tập trộn nhiều chủ đề nên không có `topicId` chung;
                // lúc đó tiến độ chủ đề không cần tăng vì từ đã học rồi.
                topicId: topicId ?? '',
                english: pair.english,
                vietnamese: pair.vietnamese,
                phonetic: '',
              ),
              isCorrect: isCorrect,
            )
            .catchError(
              // Không chặn người học vì một lần ghi thất bại; họ đã làm xong
              // bài.
              (Object error) =>
                  debugPrint('Không ghi được tiến độ cho ${pair.id}: $error'),
            ),
    ]);

    // Ghi xong mới báo: XP / hạt / streak / tiến độ chủ đề / lịch ôn ở các tab
    // khác tự tải lại. Nếu báo trước khi ghi xong thì chúng đọc lại đúng số cũ.
    //
    // `ref.read` thay vì `ref.watch` vì đây là lúc ghi, không phải phụ thuộc —
    // và phiên học không được tự tải lại giữa lúc người ta đang làm bài.
    ref.read(userDataRevisionProvider.notifier).bump();
  }

  /// Gửi kết quả lên server.
  ///
  /// Cố tình **không** đẩy lỗi ra UI: người học đã làm xong bài, chặn họ ở màn
  /// hình lỗi chỉ vì gọi mạng thất bại là vô lý. Ghi log để còn lần ra được.
  Future<void> _submitResult(SessionProgress progress) async {
    try {
      await ref
          .read(learnRepositoryProvider)
          .submitResult(progress.session.id, progress.toResult());
    } on Failure catch (failure) {
      debugPrint('Không gửi được kết quả phiên học: ${failure.message}');
    }
  }
}

final sessionProvider =
    AsyncNotifierProvider.family<
      SessionController,
      SessionProgress,
      SessionKey
    >(SessionController.new);
