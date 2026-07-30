import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/theme/app_theme.dart';
import 'package:parrot/shared/widgets/primary_button.dart';
import 'package:parrot/shared/widgets/topic_chip.dart';
import 'package:parrot/shared/widgets/vocab_card.dart';

/// Bọc widget trong đủ ngữ cảnh Material + theme của app để test.
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('PrimaryButton', () {
    testWidgets('gọi onPressed khi bấm', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Lưu', onPressed: () => tapCount++)),
      );

      await tester.tap(find.text('Lưu'));
      expect(tapCount, 1);
    });

    testWidgets('bị vô hiệu hoá khi onPressed là null', (tester) async {
      await tester.pumpWidget(_wrap(const PrimaryButton(label: 'Lưu')));

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('đang tải thì hiện spinner thay vì chữ', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Lưu', isLoading: true, onPressed: () {})),
      );

      expect(find.text('Lưu'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('TopicChip', () {
    testWidgets('chưa chọn thì hiện lời mời chọn chủ đề', (tester) async {
      await tester.pumpWidget(_wrap(TopicChip(onTap: () {})));
      expect(find.text('chọn chủ đề'), findsOneWidget);
    });

    testWidgets('đã chọn thì hiện tên chủ đề', (tester) async {
      await tester.pumpWidget(
        _wrap(TopicChip(topic: 'Văn phòng', onTap: () {})),
      );
      expect(find.text('Văn phòng'), findsOneWidget);
      expect(find.text('chọn chủ đề'), findsNothing);
    });
  });

  group('VocabCard', () {
    Widget buildCard({
      bool isSelected = false,
      ValueChanged<bool>? onSelectedChanged,
    }) {
      return _wrap(
        VocabCard(
          english: 'chair',
          vietnamese: 'cái ghế',
          phonetic: '/tʃeə(r)/',
          isSelected: isSelected,
          onSelectedChanged: onSelectedChanged,
          onSpeak: () {},
          onTopicTap: () {},
        ),
      );
    }

    testWidgets('hiện từ, phiên âm và nghĩa', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text('chair'), findsOneWidget);
      expect(find.text('/tʃeə(r)/ – cái ghế'), findsOneWidget);
    });

    testWidgets('bấm vào thẻ thì đảo trạng thái chọn', (tester) async {
      bool? received;
      await tester.pumpWidget(
        buildCard(onSelectedChanged: (value) => received = value),
      );

      await tester.tap(find.text('chair'));
      expect(received, isTrue);
    });

    testWidgets('không có ô chọn khi onSelectedChanged là null', (
      tester,
    ) async {
      await tester.pumpWidget(buildCard());

      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('đang chọn thì hiện dấu tick', (tester) async {
      await tester.pumpWidget(
        buildCard(isSelected: true, onSelectedChanged: (_) {}),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
