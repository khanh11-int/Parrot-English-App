import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/router/app_routes.dart';
import 'package:parrot/features/flashcard/domain/entities/review_deck.dart';
import 'package:parrot/features/flashcard/domain/repositories/review_repository.dart';
import 'package:parrot/features/flashcard/presentation/providers/review_providers.dart';
import 'package:parrot/shared/widgets/primary_button.dart';

import 'helpers/test_app.dart';

/// Trả về đúng bộ từ mà test cần, không có độ trễ giả.
class _FixedReviewRepository implements ReviewRepository {
  const _FixedReviewRepository(this.decks);

  final List<ReviewDeck> decks;

  @override
  Future<List<ReviewDeck>> getDecks() async => decks;
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

    expect(find.text('Đã học 8/8 từ · thuộc 2'), findsOneWidget);
    expect(find.text('3 từ đến hạn ôn'), findsOneWidget);
  });
}
