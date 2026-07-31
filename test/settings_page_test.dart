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

    // Ba mục thật vẫn phải còn.
    expect(find.text('Tên hiển thị'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
  });

  testWidgets('đổi được tên hiển thị', (tester) async {
    final router = await pumpParrotApp(tester);
    router.push(AppRoutes.settings);
    await settleMockData(tester);

    // Mock đăng nhập sẵn với tên "Công Tình".
    expect(find.text('Công Tình'), findsOneWidget);

    await tester.tap(find.text('Tên hiển thị'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Bánh Tráng Nướng');
    await tester.tap(find.text('Lưu'));
    await settleMockData(tester);

    expect(find.text('Bánh Tráng Nướng'), findsOneWidget);
    expect(find.text('Công Tình'), findsNothing);
  });

  testWidgets('tên trống bị chặn, không lưu', (tester) async {
    final router = await pumpParrotApp(tester);
    router.push(AppRoutes.settings);
    await settleMockData(tester);

    await tester.tap(find.text('Tên hiển thị'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '  ');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    // Hộp thoại vẫn mở và báo lỗi, tên cũ không bị ghi đè bằng chuỗi rỗng.
    expect(find.text('Vui lòng nhập tên của bạn.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
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
