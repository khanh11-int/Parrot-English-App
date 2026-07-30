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

  // --- Nhóm học tập ----------------------------------------------------

  /// Các nhóm có thể tham gia.
  Future<List<StudyGroupSummary>> getJoinableGroups();

  /// Tạo nhóm mới và tự tham gia luôn với vai trò trưởng nhóm.
  Future<void> createGroup(String name);

  /// Tham gia một nhóm đã có.
  Future<void> joinGroup(String groupId);

  /// Rời nhóm hiện tại.
  Future<void> leaveGroup();

  // --- Chat nhóm & bình luận -------------------------------------------

  /// Tin nhắn trong nhóm, cập nhật liên tục.
  ///
  /// Dùng `Stream` chứ không phải `Future`: chat cần thấy tin người khác gửi
  /// ngay, không phải kéo để làm mới.
  Stream<List<ChatMessage>> watchGroupMessages(String groupId);

  Future<void> sendGroupMessage(
    String groupId, {
    String? text,
    String? stickerAsset,
  });

  /// Bình luận dưới một bài đăng, cập nhật liên tục.
  Stream<List<ChatMessage>> watchPostComments(String postId);

  Future<void> sendPostComment(
    String postId, {
    String? text,
    String? stickerAsset,
  });
}
