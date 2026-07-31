import '../entities/community_entities.dart';

/// Nguồn dữ liệu Cộng đồng: xếp hạng và nhóm học tập.
///
/// Bản này **không có dòng thời gian**, nên không có bài đăng, thích, lưu bài
/// hay bình luận — chỉ còn nhóm học tập và bảng xếp hạng.
abstract interface class CommunityRepository {
  Future<Leaderboard> getLeaderboard();

  /// Nhóm học tập của người dùng; `null` nếu chưa tham gia nhóm nào.
  Future<StudyGroup?> getStudyGroup();

  // --- Nhóm học tập ----------------------------------------------------

  /// Các nhóm có thể tham gia.
  Future<List<StudyGroupSummary>> getJoinableGroups();

  /// Tạo nhóm mới và tự tham gia luôn với vai trò trưởng nhóm.
  Future<void> createGroup(String name);

  /// Tham gia một nhóm đã có.
  Future<void> joinGroup(String groupId);

  /// Rời nhóm hiện tại.
  Future<void> leaveGroup();

  // --- Chat nhóm -------------------------------------------------------

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
}
