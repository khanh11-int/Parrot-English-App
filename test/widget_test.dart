import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('App khởi động và hiện thanh điều hướng dưới', (tester) async {
    await pumpParrotApp(tester);

    // Thanh nav thuộc vỏ app nên luôn hiện, độc lập với nội dung từng tab.
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Ôn tập'), findsOneWidget);
    expect(find.text('Cộng đồng'), findsOneWidget);
    expect(find.text('Hồ sơ'), findsOneWidget);
  });

  testWidgets('Trang chủ hiện lời chào, thẻ hành động và nhiệm vụ', (
    tester,
  ) async {
    await pumpParrotApp(tester);

    expect(find.text('Chào Công Tình 👋'), findsOneWidget);
    expect(find.text('Gửi ảnh học từ mới!'), findsOneWidget);
    // Hai thẻ hành động chỉ có nhãn, không hiện tiến độ.
    expect(find.text('Học từ mới'), findsOneWidget);
    expect(find.text('Ôn tập ngay'), findsOneWidget);
    expect(find.textContaining('9/15'), findsNothing);
    // Nhiệm vụ hằng ngày hiện từng dòng chứ không còn tiêu đề nhóm.
    expect(find.text('Lưu 5 từ mới qua hình ảnh'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets('Bấm tab Cộng đồng thì chuyển trang', (tester) async {
    await pumpParrotApp(tester);

    await tester.tap(find.text('Cộng đồng'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Cộng đồng'), findsOneWidget);
  });
}
