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
    // Bản này không có camera nên trang chủ không còn banner gửi ảnh.
    expect(find.text('Gửi ảnh học từ mới!'), findsNothing);
    // Hai thẻ hành động chỉ có nhãn, không hiện tiến độ.
    expect(find.text('Học từ mới'), findsOneWidget);
    expect(find.text('Ôn tập ngay'), findsOneWidget);
    expect(find.textContaining('9/15'), findsNothing);
    // Mục nhiệm vụ ngày có tên riêng, không gộp dưới một chữ "Nhiệm vụ".
    expect(find.text('Hôm nay'), findsOneWidget);
    // Nhiệm vụ hằng ngày hiện từng dòng chứ không còn tiêu đề nhóm.
    expect(find.text('Lưu 5 từ mới qua hình ảnh'), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
  });

  testWidgets('Thẻ Hành trình hiện số từ đã học, không chỉ phần trăm', (
    tester,
  ) async {
    await pumpParrotApp(tester);

    // Thẻ nằm cuối trang, ngoài khung 600dp của test nên phải cuộn tới —
    // `ListView` không dựng phần tử chưa lọt vào khung nhìn.
    await tester.scrollUntilVisible(
      find.text('Hành trình'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Mock: 45/152 từ. Trước đây hai số này bị nhồi vào chuỗi tiêu đề của một
    // `Quest` nên trang chủ chỉ hiện được `30%`.
    expect(find.text('45/152 từ trong giáo trình'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
  });

  testWidgets('Bấm tab Cộng đồng thì chuyển trang', (tester) async {
    await pumpParrotApp(tester);

    await tester.tap(find.text('Cộng đồng'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Cộng đồng'), findsOneWidget);
  });
}
