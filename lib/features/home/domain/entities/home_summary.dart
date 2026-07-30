/// Một mục tiêu có tiến độ dạng "đã làm / cần làm".
class DailyGoal {
  const DailyGoal({
    required this.title,
    required this.completed,
    required this.target,
  });

  final String title;
  final int completed;
  final int target;

  /// Tỉ lệ hoàn thành trong khoảng 0..1.
  ///
  /// Chặn chia cho 0 để mục tiêu cấu hình sai không làm crash UI.
  double get progress => target <= 0 ? 0 : (completed / target).clamp(0.0, 1.0);

  bool get isCompleted => completed >= target;
}

/// Một nhiệm vụ trong danh sách nhiệm vụ hằng ngày / hằng tháng.
class Quest {
  const Quest({
    required this.title,
    required this.completed,
    required this.target,
  });

  final String title;
  final int completed;
  final int target;

  double get progress => target <= 0 ? 0 : (completed / target).clamp(0.0, 1.0);

  bool get isCompleted => completed >= target;

  /// Phần trăm làm tròn, dùng hiển thị "60%".
  int get percent => (progress * 100).round();
}

/// Nhóm nhiệm vụ có tiêu đề riêng ("Nhiệm vụ tháng Chín", "Nhiệm vụ hằng ngày").
class QuestGroup {
  const QuestGroup({required this.title, required this.quests});

  final String title;
  final List<Quest> quests;

  /// Tiến độ chung của cả nhóm = trung bình tiến độ các nhiệm vụ con.
  double get progress {
    if (quests.isEmpty) return 0;
    final total = quests.fold<double>(0, (sum, q) => sum + q.progress);
    return total / quests.length;
  }

  int get percent => (progress * 100).round();
}

/// Toàn bộ dữ liệu cần để vẽ trang chủ.
class HomeSummary {
  const HomeSummary({
    required this.userName,
    required this.streakDays,
    required this.gemCount,
    required this.seedCount,
    required this.learnGoal,
    required this.reviewGoal,
    required this.monthlyQuest,
    required this.dailyQuests,
  });

  /// Tên người dùng, để trang chủ chào đúng tên.
  final String userName;
  final int streakDays;
  final int gemCount;
  final int seedCount;
  final DailyGoal learnGoal;
  final DailyGoal reviewGoal;
  final QuestGroup monthlyQuest;
  final QuestGroup dailyQuests;
}
