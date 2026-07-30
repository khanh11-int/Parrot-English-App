/// Đường dẫn của mọi endpoint. Xem `docs/API_SPEC.md` để biết request/response.
///
/// Gom một chỗ để backend đổi đường dẫn thì chỉ sửa ở đây, và để nhìn được toàn
/// bộ bề mặt API của app trong một file.
abstract final class ApiEndpoints {
  // --- Người dùng hiện tại ---------------------------------------------
  static const home = '/me/home';
  static const profile = '/me/profile';
  static const decks = '/me/decks';
  static const studyGroup = '/me/group';

  // --- Nhận diện ảnh ----------------------------------------------------
  static const scans = '/scans';

  /// Hỏi kết quả của một lần nhận diện đang xử lý.
  static String scan(String scanId) => '/scans/$scanId';

  static const topics = '/topics';
  static const vocabulary = '/vocabulary';

  // --- Phiên học & ôn tập -----------------------------------------------
  /// Danh sách chủ đề kèm tiến độ học của người dùng.
  static const learnTopics = '/me/topics';
  static const learnSession = '/sessions/learn';
  static const reviewSession = '/sessions/review';

  static String sessionResult(String sessionId) =>
      '/sessions/$sessionId/result';

  // --- Cộng đồng --------------------------------------------------------
  static const feed = '/feed';
  static const posts = '/posts';
  static const leaderboard = '/leaderboard';

  static String postLike(String postId) => '/posts/$postId/like';
  static String postBookmark(String postId) => '/posts/$postId/bookmark';

  // --- Cửa hàng ---------------------------------------------------------
  static const shop = '/shop';
  static const purchases = '/shop/purchases';
}
