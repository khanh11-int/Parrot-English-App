import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/router/app_routes.dart';
import 'package:parrot/features/flashcard/domain/entities/review_deck.dart';
import 'package:parrot/features/flashcard/domain/repositories/review_repository.dart';
import 'package:parrot/features/flashcard/presentation/pages/review_page.dart';
import 'package:parrot/features/flashcard/presentation/providers/review_providers.dart';
import 'package:parrot/features/quiz/domain/entities/exercise.dart';
import 'package:parrot/features/quiz/domain/entities/learn_session.dart';
import 'package:parrot/features/quiz/domain/entities/session_result.dart';
import 'package:parrot/features/quiz/domain/entities/word_pair.dart';
import 'package:parrot/features/quiz/domain/repositories/learn_repository.dart';
import 'package:parrot/features/quiz/presentation/providers/learn_providers.dart';
import 'package:parrot/shared/widgets/primary_button.dart';

import 'helpers/test_app.dart';

/// Trả về đúng bộ từ mà test cần, không có độ trễ giả.
class _FixedReviewRepository implements ReviewRepository {
  const _FixedReviewRepository(this.decks);

  final List<ReviewDeck> decks;

  @override
  Future<List<ReviewDeck>> getDecks() async => decks;
}

/// Ghi lại `topicId` mà phiên ôn tập được yêu cầu.
class _SpyLearnRepository implements LearnRepository {
  final reviewTopicIds = <String?>[];

  @override
  Future<LearnSession> getReviewSession({String? topicId}) async {
    reviewTopicIds.add(topicId);
    return const LearnSession(
      id: 'spy-review',
      title: 'Ôn tập',
      exercises: [
        MultipleChoiceExerciseData(
          word: WordPair(id: 'chair', english: 'chair', vietnamese: 'cái ghế'),
          options: ['cái ghế', 'cái bàn', 'cái giường', 'cái tủ'],
          correctOption: 'cái ghế',
        ),
      ],
    );
  }

  @override
  Future<LearnSession> getLearnSession({String? topicId}) =>
      throw UnimplementedError();

  @override
  Future<void> submitResult(String sessionId, SessionResult result) async {}
}

Override _withDecks(List<ReviewDeck> decks) =>
    reviewRepositoryProvider.overrideWithValue(_FixedReviewRepository(decks));

/// Nút "ôn tập" là nút chính duy nhất trên trang.
bool _startButtonEnabled(WidgetTester tester) {
  final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
  return button.onPressed != null;
}

void main() {
  testWidgets('học rồi mà chưa tới hạn thì vẫn ôn lại được', (tester) async {
    // Đúng tình huống người dùng gặp: học xong hai chủ đề, lịch SRS hẹn hôm sau
    // nên không còn từ nào đến hạn. Trước đây nút bị xám và tab Ôn tập vô dụng.
    final router = await pumpParrotApp(
      tester,
      extraOverrides: [
        _withDecks(const [
          ReviewDeck(
            topicId: 'health',
            topic: 'Sức khoẻ',
            totalCount: 8,
            learnedCount: 8,
            masteredCount: 0,
            dueCount: 0,
          ),
        ]),
      ],
    );
    router.go(AppRoutes.review);
    await settleMockData(tester);

    expect(find.text('Không còn từ nào đến hạn'), findsOneWidget);
    expect(find.text('Ôn lại từ đã học'), findsOneWidget);
    expect(_startButtonEnabled(tester), isTrue);
  });

  testWidgets('chưa học từ nào thì nút bị vô hiệu hoá', (tester) async {
    final router = await pumpParrotApp(
      tester,
      extraOverrides: [
        _withDecks(const [
          ReviewDeck(
            topicId: 'health',
            topic: 'Sức khoẻ',
            totalCount: 8,
            learnedCount: 0,
            masteredCount: 0,
            dueCount: 0,
          ),
        ]),
      ],
    );
    router.go(AppRoutes.review);
    await settleMockData(tester);

    expect(find.text('Chưa có gì để ôn'), findsOneWidget);
    expect(_startButtonEnabled(tester), isFalse);
  });

  testWidgets('thẻ bộ từ đếm theo số từ đã học, không phải số từ đã thuộc', (
    tester,
  ) async {
    // "Đã thuộc" cần ôn đúng vài lần trong ba tuần, nên nếu thẻ chỉ hiện số đó
    // thì chủ đề vừa học xong vẫn báo 0 — ngược hẳn trang Học từ mới báo 8/8.
    final router = await pumpParrotApp(
      tester,
      extraOverrides: [
        _withDecks(const [
          ReviewDeck(
            topicId: 'family',
            topic: 'Gia đình',
            totalCount: 8,
            learnedCount: 8,
            masteredCount: 2,
            dueCount: 3,
          ),
        ]),
      ],
    );
    router.go(AppRoutes.review);
    await settleMockData(tester);

    expect(find.text('Đã học 8/8 từ · đã thuộc 2 từ'), findsOneWidget);
    expect(find.text('3 từ đến hạn ôn'), findsOneWidget);
  });

  testWidgets('chủ đề chưa học bị ẩn, gom thành một dòng dẫn sang Học từ mới', (
    tester,
  ) async {
    // Chủ đề chưa chạm tới thì không ôn được. Liệt kê chúng ở đây chỉ đẩy phần
    // dùng được xuống dưới màn hình — người dùng phải cuộn qua 5 thẻ chết.
    final router = await pumpParrotApp(
      tester,
      extraOverrides: [
        _withDecks(const [
          ReviewDeck(
            topicId: 'health',
            topic: 'Sức khoẻ',
            totalCount: 8,
            learnedCount: 8,
            masteredCount: 0,
            dueCount: 2,
          ),
          ReviewDeck(
            topicId: 'office',
            topic: 'Văn phòng',
            totalCount: 8,
            learnedCount: 0,
            masteredCount: 0,
            dueCount: 0,
          ),
          ReviewDeck(
            topicId: 'food',
            topic: 'Đồ ăn thức uống',
            totalCount: 8,
            learnedCount: 0,
            masteredCount: 0,
            dueCount: 0,
          ),
        ]),
      ],
    );
    router.go(AppRoutes.review);
    await settleMockData(tester);

    expect(find.text('Sức khoẻ'), findsOneWidget);
    expect(find.text('Văn phòng'), findsNothing);
    expect(find.text('Đồ ăn thức uống'), findsNothing);
    expect(find.text('Còn 2 chủ đề chưa học'), findsOneWidget);
  });

  testWidgets('bộ từ có từ đến hạn được xếp lên trước', (tester) async {
    final router = await pumpParrotApp(
      tester,
      extraOverrides: [
        _withDecks(const [
          ReviewDeck(
            topicId: 'health',
            topic: 'Sức khoẻ',
            totalCount: 8,
            learnedCount: 8,
            masteredCount: 0,
            dueCount: 0,
          ),
          ReviewDeck(
            topicId: 'family',
            topic: 'Gia đình',
            totalCount: 8,
            learnedCount: 3,
            masteredCount: 0,
            dueCount: 3,
          ),
        ]),
      ],
    );
    router.go(AppRoutes.review);
    await settleMockData(tester);

    // Gia đình có 3 từ đến hạn nên phải nằm trên Sức khoẻ, dù học ít hơn.
    final family = tester.getTopLeft(find.text('Gia đình')).dy;
    final health = tester.getTopLeft(find.text('Sức khoẻ')).dy;
    expect(family, lessThan(health));
  });

  testWidgets('bấm một bộ từ thì mở phiên ôn riêng chủ đề đó', (tester) async {
    // Kiểm tận nơi nhận: repository phải được gọi với đúng `topicId`. Nếu chỉ
    // kiểm đường dẫn thì thiếu một mắt — route có param nhưng `SessionKey`
    // không mang nó xuống repository là test vẫn xanh.
    final spy = _SpyLearnRepository();
    final router = await pumpParrotApp(
      tester,
      extraOverrides: [
        _withDecks(const [
          ReviewDeck(
            topicId: 'health',
            topic: 'Sức khoẻ',
            totalCount: 8,
            learnedCount: 8,
            masteredCount: 0,
            dueCount: 2,
          ),
        ]),
        learnRepositoryProvider.overrideWithValue(spy),
      ],
    );
    router.go(AppRoutes.review);
    await settleMockData(tester);

    await tester.tap(find.text('Sức khoẻ'));
    await settleMockData(tester);

    expect(spy.reviewTopicIds, ['health']);
    expect(find.text("'chair' có nghĩa là gì?"), findsOneWidget);
  });

  testWidgets('nút lớn ôn trộn mọi chủ đề, không kèm topicId', (tester) async {
    final spy = _SpyLearnRepository();
    final router = await pumpParrotApp(
      tester,
      extraOverrides: [
        _withDecks(const [
          ReviewDeck(
            topicId: 'health',
            topic: 'Sức khoẻ',
            totalCount: 8,
            learnedCount: 8,
            masteredCount: 0,
            dueCount: 2,
          ),
        ]),
        learnRepositoryProvider.overrideWithValue(spy),
      ],
    );
    router.go(AppRoutes.review);
    await settleMockData(tester);

    await tester.tap(find.text('Ôn tập ngay'));
    await settleMockData(tester);

    expect(spy.reviewTopicIds, [null]);
  });

  group('describeDueIn', () {
    final now = DateTime(2026, 8, 1, 20);

    test('đếm theo ngày lịch, không theo số giờ chênh lệch', () {
      // 20h hôm nay tới 8h mai chỉ cách 12 tiếng, nhưng người học gọi đó là
      // "mai". Chia cho 24 tiếng thì ra "hôm nay", sai với cách người ta nói.
      expect(describeDueIn(DateTime(2026, 8, 2, 8), now: now), 'mai');
    });

    test('quá hạn hoặc đến hạn trong ngày đều là hôm nay', () {
      expect(describeDueIn(DateTime(2026, 8, 1, 6), now: now), 'hôm nay');
      expect(describeDueIn(DateTime(2026, 7, 20), now: now), 'hôm nay');
    });

    test('xa hơn thì đếm ngày', () {
      expect(describeDueIn(DateTime(2026, 8, 4), now: now), '3 ngày nữa');
    });

    test('không có mốc thì trả null để chỗ gọi tự xử', () {
      expect(describeDueIn(null, now: now), isNull);
    });
  });
}
