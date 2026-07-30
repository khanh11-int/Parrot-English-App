import '../entities/community_entities.dart';

/// Nguồn dữ liệu Cộng đồng: dòng thời gian, xếp hạng, nhóm học tập.
abstract interface class CommunityRepository {
  /// Dòng thời gian. Ném `Failure` nếu thất bại.
  Future<List<CommunityPost>> getFeed();

  Future<Leaderboard> getLeaderboard();

  /// Nhóm học tập của người dùng; `null` nếu chưa tham gia nhóm nào.
  Future<StudyGroup?> getStudyGroup();

  /// Bật/tắt thích một bài đăng, trả về bài đăng sau khi cập nhật.
  Future<CommunityPost> setLiked(String postId, {required bool isLiked});

  /// Bật/tắt lưu một bài đăng, trả về bài đăng sau khi cập nhật.
  Future<CommunityPost> setBookmarked(
    String postId, {
    required bool isBookmarked,
  });

  /// Đăng một từ vựng lên dòng thời gian.
  ///
  /// [detectedLabel] là nhãn AI đọc được từ ảnh, ví dụ `chair - cái ghế 0.98`.
  /// Chưa gửi ảnh kèm vì chưa dùng Cloud Storage.
  Future<void> createPost({
    required SharedWord word,
    required String detectedLabel,
  });
}
