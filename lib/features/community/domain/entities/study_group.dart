import '../../../../core/constants/app_labels.dart';

/// Nhóm học tập **mà người dùng đang ở trong**.
///
/// Bản rút gọn cho danh sách nhóm chưa tham gia là [StudyGroupSummary].
class StudyGroup {
  const StudyGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.leaderName,
    required this.avatarAsset,
    required this.totalExperience,
    required this.daysRemaining,
    this.isLeader = false,
  });

  final String id;
  final String name;
  final int memberCount;
  final String leaderName;

  /// Người dùng hiện tại có phải trưởng nhóm.
  final bool isLeader;
  final String avatarAsset;

  /// XP tích luỹ của cả nhóm.
  final int totalExperience;

  /// Số ngày còn lại của mùa hiện tại.
  final int daysRemaining;

  /// Mốc cao nhất nhóm đã đạt; `null` nếu chưa đạt mốc nào.
  GroupMilestone? get achievedMilestone {
    GroupMilestone? result;
    for (final milestone in GroupMilestone.values) {
      if (totalExperience >= milestone.requiredExperience) result = milestone;
    }
    return result;
  }

  /// Mốc nhóm đang hướng tới; `null` nếu đã đạt hết.
  GroupMilestone? get currentMilestone {
    for (final milestone in GroupMilestone.values) {
      if (totalExperience < milestone.requiredExperience) return milestone;
    }
    return null;
  }

  bool isMilestoneUnlocked(GroupMilestone milestone) =>
      totalExperience >= milestone.requiredExperience;
}
