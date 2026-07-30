import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/features/auth/domain/entities/app_user.dart';
import 'package:parrot/shared/widgets/app_text_field.dart';

import 'helpers/test_app.dart';

void main() {
  group('Chặn route', () {
    testWidgets('Chưa đăng nhập thì bị đẩy về trang đăng nhập', (tester) async {
      await pumpParrotApp(tester, isSignedIn: false);

      expect(find.text('Chào mừng trở lại!'), findsOneWidget);
      // Không được thấy thanh nav của app.
      expect(find.text('Trang chủ'), findsNothing);
    });

    testWidgets('Đã đăng nhập thì vào thẳng trang chủ', (tester) async {
      await pumpParrotApp(tester);

      expect(find.text('Chào mừng trở lại!'), findsNothing);
      expect(find.text('Trang chủ'), findsOneWidget);
    });
  });

  group('Trang đăng nhập', () {
    testWidgets('Bấm đăng nhập khi để trống thì báo lỗi từng ô', (
      tester,
    ) async {
      await pumpParrotApp(tester, isSignedIn: false);

      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      expect(find.text('Vui lòng nhập email.'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu.'), findsOneWidget);
    });

    testWidgets('Email sai định dạng thì báo lỗi', (tester) async {
      await pumpParrotApp(tester, isSignedIn: false);

      await tester.enterText(
        find.byType(AppTextField).first,
        'khong-phai-email',
      );
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      expect(find.text('Email không hợp lệ.'), findsOneWidget);
    });

    testWidgets('Mật khẩu dưới 6 ký tự thì báo lỗi ngay ở client', (
      tester,
    ) async {
      await pumpParrotApp(tester, isSignedIn: false);

      final fields = find.byType(AppTextField);
      await tester.enterText(fields.first, 'a@b.com');
      await tester.enterText(fields.last, '123');
      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      expect(find.text('Mật khẩu cần ít nhất 6 ký tự.'), findsOneWidget);
    });

    testWidgets('Đăng nhập đúng thì vào được app', (tester) async {
      await pumpParrotApp(tester, isSignedIn: false);

      final fields = find.byType(AppTextField);
      await tester.enterText(fields.first, 'cong.tinh@example.com');
      await tester.enterText(fields.last, 'matkhau123');
      await tester.tap(find.text('Đăng nhập'));
      await settleMockData(tester);

      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Chào mừng trở lại!'), findsNothing);
    });

    testWidgets('Mở được trang đăng ký từ trang đăng nhập', (tester) async {
      await pumpParrotApp(tester, isSignedIn: false);

      await tester.tap(find.text('Đăng ký ngay'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Tạo tài khoản'), findsOneWidget);
      expect(find.text('Tên của bạn'), findsOneWidget);
    });
  });

  group('AuthValidators', () {
    test('email', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('khong-co-a-móc'), isNotNull);
      expect(AuthValidators.email('a@b'), isNotNull, reason: 'thiếu dấu chấm');
      expect(AuthValidators.email('@b.com'), isNotNull, reason: 'thiếu tên');
      expect(AuthValidators.email('a@b.com'), isNull);
      expect(AuthValidators.email('  a@b.com  '), isNull, reason: 'cắt space');
    });

    test('password', () {
      expect(AuthValidators.password(''), isNotNull);
      expect(AuthValidators.password('12345'), isNotNull);
      expect(AuthValidators.password('123456'), isNull);
    });

    test('displayName', () {
      expect(AuthValidators.displayName(''), isNotNull);
      expect(AuthValidators.displayName(' a '), isNotNull, reason: 'quá ngắn');
      expect(AuthValidators.displayName('Công Tình'), isNull);
    });
  });

  group('AppUser', () {
    test('greetingName lấy displayName nếu có', () {
      const user = AppUser(
        id: '1',
        email: 'cong.tinh@example.com',
        displayName: 'Công Tình',
      );
      expect(user.greetingName, 'Công Tình');
    });

    test('greetingName lấy phần trước @ khi chưa có tên', () {
      const user = AppUser(id: '1', email: 'cong.tinh@example.com');
      expect(user.greetingName, 'cong.tinh');
    });

    test('greetingName bỏ qua tên chỉ có khoảng trắng', () {
      const user = AppUser(
        id: '1',
        email: 'ai.do@example.com',
        displayName: '  ',
      );
      expect(user.greetingName, 'ai.do');
    });
  });
}
