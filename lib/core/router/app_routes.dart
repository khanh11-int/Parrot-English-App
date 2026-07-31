/// Đường dẫn của mọi route. Dùng hằng số thay vì viết chuỗi trực tiếp để đổi
/// đường dẫn không phải đi tìm khắp code.
abstract final class AppRoutes {
  // Xác thực — hai route duy nhất vào được khi chưa đăng nhập
  static const login = '/login';
  static const register = '/register';

  /// Các route không cần đăng nhập.
  static const publicRoutes = {login, register};

  // 4 tab gốc
  static const home = '/home';
  static const review = '/review';
  static const community = '/community';
  static const profile = '/profile';

  // Phiên học & ôn tập (toàn màn hình, ẩn thanh nav)
  /// Danh sách chủ đề để chọn học — bước trước khi vào phiên học.
  static const learnTopics = '/learn';
  static const learnSession = '/learn/session';
  static const reviewSession = '/review-session';

  /// Phiên ôn tập của một chủ đề cụ thể.
  static String reviewSessionOfTopic(String topicId) =>
      '$reviewSession?$topicIdParam=$topicId';

  /// Tên tham số truy vấn mang id chủ đề sang phiên học.
  static const topicIdParam = 'topic';

  /// Phiên học của một chủ đề cụ thể.
  static String learnSessionOfTopic(String topicId) =>
      '$learnSession?$topicIdParam=$topicId';

  // Trang con
  static const shop = '/shop';

  /// Chat của nhóm học tập.
  static const groupChat = '/group-chat';

  /// Tên tham số truy vấn mang id nhóm.
  static const threadIdParam = 'id';

  static String groupChatOf(String groupId) =>
      '$groupChat?$threadIdParam=$groupId';

  static const settings = '/settings';
}
