/// Lỗi đã được phân loại để UI biết hiển thị gì và có cho thử lại hay không.
///
/// Tầng `data` không để lộ `DioException` ra ngoài: tầng trên chỉ cần biết
/// "mất mạng" hay "hết phiên đăng nhập", không cần biết dự án dùng thư viện HTTP
/// nào. Đổi thư viện về sau không phải sửa UI.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Thông điệp tiếng Việt hiển thị được cho người dùng.
  final String message;

  /// Có nên hiện nút "Thử lại" không.
  bool get isRetryable => true;

  @override
  String toString() => '$runtimeType: $message';
}

/// Không có mạng, hoặc không kết nối được tới server.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng.']);
}

/// Hết phiên đăng nhập (401 / 403).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Phiên đăng nhập đã hết. Vui lòng đăng nhập lại.',
  ]);

  // Thử lại vô nghĩa khi chưa đăng nhập lại.
  @override
  bool get isRetryable => false;
}

/// Không tìm thấy dữ liệu (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Không tìm thấy dữ liệu.']);

  @override
  bool get isRetryable => false;
}

/// Request sai (400 / 422) — thường do dữ liệu người dùng nhập.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Dữ liệu gửi lên không hợp lệ.']);

  @override
  bool get isRetryable => false;
}

/// Lỗi phía server (5xx).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Máy chủ đang gặp sự cố.']);
}

/// Người dùng chủ động huỷ request.
class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Đã huỷ yêu cầu.']);

  @override
  bool get isRetryable => false;
}

/// Lỗi khi đăng nhập / đăng ký.
///
/// Thông điệp do tầng data dịch sẵn từ mã lỗi của Firebase, nên UI chỉ việc
/// hiển thị `message`.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {this.isRetryable = true});

  @override
  final bool isRetryable;
}

/// Lỗi không xác định — giữ lại để không "nuốt" lỗi im lặng.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Có lỗi xảy ra. Vui lòng thử lại.']);
}
