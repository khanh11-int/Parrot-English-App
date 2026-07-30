import '../../../../core/constants/app_labels.dart';

/// Thông tin trang cá nhân.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.avatarAsset,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.experience,
    required this.streakDays,
    required this.groupName,
    required this.recentPostCount,
  });

  final String name;
  final String avatarAsset;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final int experience;
  final int streakDays;

  /// Tên nhóm học tập; `null` nếu chưa tham gia nhóm nào.
  final String? groupName;

  /// Số ô ảnh trong lưới "Các bài đăng gần đây".
  final int recentPostCount;

  /// Hạng hiện tại, suy ra từ XP nên không thể lệch với thanh tiến độ.
  ForestRank get rank => ForestRank.fromExperience(experience);

  /// Tiến độ tới hạng kế tiếp, 0..1. Trả 1 khi đã ở hạng cao nhất.
  double get progressToNextRank {
    final next = rank.next;
    if (next == null) return 1;

    final span = next.requiredExperience - rank.requiredExperience;
    if (span <= 0) return 1;
    return ((experience - rank.requiredExperience) / span).clamp(0.0, 1.0);
  }
}
