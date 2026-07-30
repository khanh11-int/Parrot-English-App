/// Cấu hình môi trường, truyền vào lúc build bằng `--dart-define`.
///
/// Ví dụ chạy với backend thật:
/// ```bash
/// flutter run --dart-define=PARROT_API_BASE_URL=https://api.parrot.example/v1
/// ```
///
/// Không hard-code base URL trong code: mỗi môi trường (dev / staging / prod)
/// một giá trị khác nhau, và không muốn URL nội bộ nằm trong lịch sử git.
abstract final class AppConfig {
  /// Base URL của backend trung gian của **chúng ta**.
  ///
  /// App không bao giờ gọi thẳng API của nhà cung cấp AI — key phải nằm ở
  /// server, vì app mobile dịch ngược được.
  static const apiBaseUrl = String.fromEnvironment('PARROT_API_BASE_URL');

  /// Token xác thực tạm thời cho lúc phát triển. Khi có đăng nhập thật thì đọc
  /// từ secure storage thay vì `--dart-define`.
  static const apiToken = String.fromEnvironment('PARROT_API_TOKEN');

  /// Chưa khai báo base URL thì chạy bằng dữ liệu mock.
  ///
  /// Nhờ vậy app luôn mở được: người làm UI không bị chặn vì backend chưa
  /// xong, còn khi truyền base URL vào là tự động chuyển sang gọi API thật.
  static bool get useMockData => apiBaseUrl.isEmpty;

  /// Thời gian chờ cho request thường.
  static const requestTimeout = Duration(seconds: 15);

  /// Thời gian chờ khi tải ảnh lên — ảnh nặng hơn nên cần lâu hơn.
  static const uploadTimeout = Duration(seconds: 60);
}
