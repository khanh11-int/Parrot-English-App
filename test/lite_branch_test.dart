import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/router/app_routes.dart';

import 'helpers/test_app.dart';

/// Chốt phạm vi của nhánh `lite`: camera và dòng thời gian đã bị **xoá**, không
/// phải ẩn đi. Nếu ai đó lỡ trộn nhánh `main` vào đây, mấy test này đỏ ngay.
void main() {
  testWidgets('thanh điều hướng không có nút camera', (tester) async {
    await pumpParrotApp(tester);

    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.byIcon(Icons.photo_camera_rounded), findsNothing);
    // Bốn tab vẫn đủ.
    for (final label in ['Trang chủ', 'Ôn tập', 'Cộng đồng', 'Hồ sơ']) {
      expect(find.text(label), findsOneWidget, reason: 'thiếu tab $label');
    }
  });

  testWidgets('Cộng đồng chỉ còn 2 tab, không có Dòng thời gian', (
    tester,
  ) async {
    final router = await pumpParrotApp(tester);
    router.go(AppRoutes.community);
    await settleMockData(tester);

    expect(find.text('Dòng thời gian'), findsNothing);
    expect(find.text('Nhóm học tập'), findsOneWidget);
    expect(find.text('Bảng xếp hạng'), findsOneWidget);
  });

  testWidgets('trang chủ không còn banner gửi ảnh', (tester) async {
    await pumpParrotApp(tester);

    expect(find.text('Gửi ảnh học từ mới!'), findsNothing);
    expect(find.text('Gửi ảnh'), findsNothing);
  });

  testWidgets('Cài đặt không còn mục Từ đã lưu', (tester) async {
    final router = await pumpParrotApp(tester);
    router.push(AppRoutes.settings);
    await settleMockData(tester);

    expect(find.text('Từ đã lưu từ ảnh'), findsNothing);
  });
}
