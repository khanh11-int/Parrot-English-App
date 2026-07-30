import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:parrot/core/router/app_routes.dart';

import 'helpers/test_app.dart';

/// Chờ cho mọi repository mock trả dữ liệu và UI vẽ xong.
Future<void> _settle(WidgetTester tester) => settleMockData(tester);

/// Dựng app đã đăng nhập sẵn, trả về router để test tự điều hướng.
Future<GoRouter> _pumpApp(WidgetTester tester) => pumpParrotApp(tester);

void main() {
  testWidgets('4 tab gốc đều vẽ được, không lỗi', (tester) async {
    final router = await _pumpApp(tester);

    for (final route in [
      AppRoutes.home,
      AppRoutes.review,
      AppRoutes.community,
      AppRoutes.profile,
    ]) {
      router.go(route);
      await _settle(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Route $route gây lỗi khi vẽ',
      );
    }
  });

  testWidgets('các trang con đều vẽ được, không lỗi', (tester) async {
    final router = await _pumpApp(tester);

    for (final route in [
      AppRoutes.shop,
      AppRoutes.settings,
      AppRoutes.savedWords,
      AppRoutes.scan,
      AppRoutes.learnSession,
      AppRoutes.reviewSession,
    ]) {
      router.push(route);
      await _settle(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Route $route gây lỗi khi vẽ',
      );
      router.pop();
      await _settle(tester);
    }
  });

  testWidgets('Cửa hàng hiện vật phẩm theo tên chủ đề rừng', (tester) async {
    final router = await _pumpApp(tester);
    router.push(AppRoutes.shop);
    await _settle(tester);

    expect(find.text('Quả Tăng Tốc'), findsOneWidget);
    expect(find.text('Khiên Vỏ Cây'), findsOneWidget);
    expect(find.text('Bình Mật Hoa'), findsOneWidget);
  });

  testWidgets('Hồ sơ hiện hạng tầng rừng suy ra từ XP', (tester) async {
    final router = await _pumpApp(tester);
    router.go(AppRoutes.profile);
    await _settle(tester);

    // 568 XP → hạng Bụi Rậm (mốc 500).
    expect(find.text('Bụi Rậm'), findsOneWidget);
    expect(find.text('568'), findsOneWidget);
  });

  testWidgets('Ôn tập hiện tổng số từ đến hạn của mọi bộ từ', (tester) async {
    final router = await _pumpApp(tester);
    router.go(AppRoutes.review);
    await _settle(tester);

    // Mock: 6 + 9 + 0 + 15 = 30.
    expect(find.text('30 từ đến hạn ôn'), findsOneWidget);
  });

  testWidgets('Mọi tab vẽ vừa màn hình điện thoại hẹp 390dp', (tester) async {
    // UI_SPEC thiết kế cho 360–430dp, nhưng khung test mặc định rộng 800dp nên
    // không bắt được lỗi tràn layout. Ép về cỡ điện thoại thật để kiểm.
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = await _pumpApp(tester);

    for (final route in [
      AppRoutes.home,
      AppRoutes.review,
      AppRoutes.community,
      AppRoutes.profile,
      AppRoutes.shop,
      AppRoutes.learnTopics,
    ]) {
      router.go(route);
      await _settle(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Route $route tràn layout ở 390dp',
      );
    }
  });

  testWidgets('Bấm thẻ Học từ mới thì mở danh sách chủ đề có tiến độ', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    router.push(AppRoutes.learnTopics);
    await _settle(tester);

    expect(find.text('Chọn chủ đề'), findsOneWidget);
    // Mock có 7 chủ đề; kiểm vài chủ đề và nhãn tiến độ của chúng.
    expect(find.text('Sức khoẻ'), findsOneWidget);
    expect(find.text('4/18 từ'), findsOneWidget);
    expect(find.text('Còn 14 từ mới'), findsOneWidget);
    // Chủ đề học xong hiện nhãn khác.
    expect(find.text('Đã học xong'), findsOneWidget);
    // Tổng: 66/152 từ trên 7 chủ đề.
    expect(find.text('Đã học 66/152 từ'), findsOneWidget);
    expect(find.text('7 chủ đề'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chọn một chủ đề thì vào phiên học của chủ đề đó', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    router.push(AppRoutes.learnTopics);
    await _settle(tester);

    await tester.tap(find.text('Sức khoẻ'));
    await _settle(tester);

    expect(find.text('Nối các cặp từ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Phiên học chạy được vòng nối cặp', (tester) async {
    final router = await _pumpApp(tester);
    router.push(AppRoutes.learnSession);
    await _settle(tester);

    expect(find.text('Nối các cặp từ'), findsOneWidget);
    expect(find.text('Fatigue'), findsOneWidget);
    expect(find.text('Sự mệt mỏi'), findsOneWidget);

    // Ghép đúng một cặp: chọn từ tiếng Anh rồi chọn nghĩa tương ứng.
    await tester.tap(find.text('Fatigue'));
    await tester.pump();
    await tester.tap(find.text('Sự mệt mỏi'));
    await _settle(tester);

    expect(tester.takeException(), isNull);
  });
}
