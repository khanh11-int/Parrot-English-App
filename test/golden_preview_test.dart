@Tags(['preview'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/router/app_routes.dart';

import 'helpers/test_app.dart';

/// Chụp ảnh vài màn hình ra `test/preview/*.png` để xem giao diện thật thay vì
/// đoán từ code.
///
/// Không phải golden test dùng để so sánh — chỉ tạo ảnh. Chạy bằng:
///
/// ```
/// flutter test --update-goldens --run-skipped --tags preview ///   test/golden_preview_test.dart
/// ```
///
/// Thiếu `--run-skipped` thì `dart_test.yaml` bỏ qua hết, không sinh ảnh nào.
void main() {
  Future<void> shoot(
    WidgetTester tester,
    String route,
    String name, {
    Future<void> Function(WidgetTester tester)? after,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final router = await pumpParrotApp(tester);
    router.go(route);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    if (after != null) await after(tester);

    // `Image.asset` giải mã bằng I/O **thật**, mà `tester.pump` chỉ chạy đồng hồ
    // giả. Không nhường cho event loop thật thì ảnh chưa giải mã xong và ảnh
    // chụp ra thiếu hình — đúng cái đã làm mình tưởng hoạ tiết bị lỗi.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('preview/$name.png'),
    );
  }

  testWidgets('home', (t) => shoot(t, AppRoutes.home, 'home'));
  testWidgets('review', (t) => shoot(t, AppRoutes.review, 'review'));
  testWidgets('profile', (t) => shoot(t, AppRoutes.profile, 'profile'));
  testWidgets(
    'group',
    (t) => shoot(
      t,
      AppRoutes.community,
      'group',
      after: (tester) async {
        await tester.tap(find.text('Nhóm học tập'));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
      },
    ),
  );
  testWidgets(
    'leaderboard',
    (t) => shoot(
      t,
      AppRoutes.community,
      'leaderboard',
      after: (tester) async {
        await tester.tap(find.text('Bảng xếp hạng'));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
      },
    ),
  );
}
