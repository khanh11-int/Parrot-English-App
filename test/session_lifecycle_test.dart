import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/features/quiz/data/repositories/learn_mock_repository.dart';
import 'package:parrot/features/quiz/presentation/providers/learn_providers.dart';
import 'package:parrot/features/vocabulary/domain/entities/topic_word.dart';
import 'package:parrot/features/vocabulary/domain/repositories/vocabulary_repository.dart';
import 'package:parrot/features/vocabulary/presentation/providers/vocabulary_providers.dart';

/// Không chạm Firestore: bản thật đọc `FirebaseFirestore.instance`, trong test
/// chưa có `Firebase.initializeApp()` nên sẽ ném lỗi.
class _NoopVocabularyRepository implements VocabularyRepository {
  const _NoopVocabularyRepository();

  @override
  Future<List<TopicWord>> getTopicWords(String topicId) async => const [];

  @override
  Future<List<WordProgress>> getProgress({String? topicId}) async => const [];

  @override
  Future<List<WordProgress>> getDueProgress({int limit = 50}) async => const [];

  @override
  Future<void> recordAnswer({
    required TopicWord word,
    required bool isCorrect,
  }) async {}
}

void main() {
  const key = (mode: SessionMode.learn, topicId: 'health');

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        learnRepositoryProvider.overrideWithValue(const LearnMockRepository()),
        vocabularyRepositoryProvider.overrideWithValue(
          const _NoopVocabularyRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Mở một người nghe, đóng vai trang phiên học đang mở.
  ///
  /// **Bắt buộc** với provider `autoDispose`: `container.read` không giữ người
  /// nghe nào, nên provider bị dọn ngay sau mỗi lời gọi và mỗi lần `read` lại
  /// dựng một phiên mới — `completeRound` sẽ tác động lên phiên khác.
  ProviderSubscription<AsyncValue<SessionProgress>> openSession(
    ProviderContainer container,
  ) {
    // Không `addTearDown(sub.close)`: `container.dispose()` đã đóng hộ, còn test
    // về autoDispose thì tự đóng sớm.
    return container.listen(
      sessionProvider(key),
      (_, _) {},
      fireImmediately: true,
    );
  }

  Future<SessionProgress> finishSession(ProviderContainer container) async {
    await container.read(sessionProvider(key).future);
    final controller = container.read(sessionProvider(key).notifier);

    // Bản mock có 3 vòng: một vòng nối cặp + hai vòng trắc nghiệm.
    for (var i = 0; i < 3; i++) {
      controller.completeRound(isCorrect: true);
    }
    return container.read(sessionProvider(key)).requireValue;
  }

  test('làm hết các vòng thì phiên báo đã xong', () async {
    final container = makeContainer();
    openSession(container);

    final progress = await finishSession(container);

    expect(progress.isFinished, isTrue);
    expect(progress.correctCount, 3);
  });

  test('thoát khỏi phiên đã xong rồi vào lại thì được phiên MỚI', () async {
    // Đây là bug người dùng gặp: học xong 4/8 từ của một chủ đề, bấm vào chủ đề
    // đó lần nữa thì hiện luôn màn hình tổng kết cũ thay vì 4 từ tiếp theo.
    // Nguyên nhân: `sessionProvider` là family **không** autoDispose nên phiên
    // đã kết thúc được giữ lại, `isFinished` vẫn còn `true`.
    final container = makeContainer();

    final subscription = openSession(container);
    final finished = await finishSession(container);
    expect(finished.isFinished, isTrue);

    // Rời trang → không còn ai nghe → `autoDispose` dọn phiên.
    subscription.close();
    await Future<void>.delayed(Duration.zero);

    final fresh = await container.read(sessionProvider(key).future);

    expect(
      fresh.isFinished,
      isFalse,
      reason: 'vào lại phải là phiên mới, không phải màn tổng kết cũ',
    );
    expect(fresh.currentIndex, 0);
    expect(fresh.correctCount, 0);
  });

  test('trả lời sai giữa vòng chỉ tăng số sai, không chuyển vòng', () async {
    final container = makeContainer();
    openSession(container);
    await container.read(sessionProvider(key).future);
    final controller = container.read(sessionProvider(key).notifier);

    controller.recordWrongAnswer();
    final progress = container.read(sessionProvider(key)).requireValue;

    expect(progress.wrongCount, 1);
    expect(progress.currentIndex, 0);
  });
}
