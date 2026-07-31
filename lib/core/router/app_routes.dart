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

  // Luồng nhận diện ảnh
  static const scan = '/scan';
  static const scanResult = '/scan/result';

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

  /// Sổ tay từ đã lưu từ ảnh chụp.
  /// Chat của nhóm học tập.
  static const groupChat = '/group-chat';

  /// Bình luận của một bài đăng.
  static const postComments = '/post-comments';

  /// Tên tham số truy vấn mang id nhóm hoặc id bài đăng.
  static const threadIdParam = 'id';

  static String groupChatOf(String groupId) =>
      '$groupChat?$threadIdParam=$groupId';

  static String postCommentsOf(String postId) =>
      '$postComments?$threadIdParam=$postId';

  static const savedWords = '/saved-words';
  static const settings = '/settings';
}
