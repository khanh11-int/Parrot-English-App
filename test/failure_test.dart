import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/error/failure.dart';

/// `AsyncValueView` dựa vào `isRetryable` để quyết định có hiện nút "Thử lại"
/// hay không, nên phân loại sai là người dùng bấm thử lại mãi vào một lỗi không
/// bao giờ tự khỏi.
void main() {
  group('Failure.isRetryable', () {
    test('lỗi không sửa được bằng thử lại thì không cho thử lại', () {
      expect(const UnauthorizedFailure().isRetryable, isFalse);
      expect(const ValidationFailure().isRetryable, isFalse);
      expect(const NotFoundFailure().isRetryable, isFalse);
    });

    test('lỗi tạm thời thì cho thử lại', () {
      expect(const NetworkFailure().isRetryable, isTrue);
      expect(const ServerFailure().isRetryable, isTrue);
    });
  });
}
