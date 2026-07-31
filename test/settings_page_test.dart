import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/router/app_routes.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('Cài đặt chỉ còn thẻ tài khoản', (tester) async {
    final router = await pumpParrotApp(tester);
    router.push(AppRoutes.settings);
    await settleMockData(tester);

    // Danh sách 6 mục cũ đều `onTap: null` — một danh sách chỉ để ngắm, đã bỏ.
    for (final label in [
      'Thông báo',
      'Tin nhắn',
      'Thống kê học tập',
      'Thành tích',
      'Nhiệm vụ',
      'Hồ sơ của tôi',
    ]) {
      expect(find.text(label), findsNothing, reason: 'còn sót mục "$label"');
    }

    // Thứ duy nhất trên trang này bấm được vẫn phải còn.
    expect(find.text('Đang đăng nhập'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('bấm Đăng xuất thì hỏi xác nhận trước', (tester) async {
    final router = await pumpParrotApp(tester);
    router.push(AppRoutes.settings);
    await settleMockData(tester);

    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    // Đăng xuất là việc khó lùi nên phải qua một bước xác nhận.
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Bạn sẽ cần đăng nhập lại để tiếp tục học.'), findsOne);
  });
}
