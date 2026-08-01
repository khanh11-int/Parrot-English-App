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

  /// Tỉ lệ hoàn thành trong khoảng 0..1.
  ///
  /// Chặn chia cho 0 để nhiệm vụ cấu hình sai không làm crash UI, và kẹp ở 1 để
  /// làm vượt mục tiêu không đẩy thanh tiến độ tràn ra ngoài.
  double get progress => target <= 0 ? 0 : (completed / target).clamp(0.0, 1.0);

  bool get isCompleted => completed >= target;

  /// Phần trăm làm tròn, dùng hiển thị "60%".
  int get percent => (progress * 100).round();
}

/// Nhóm nhiệm vụ có tiêu đề riêng ("Nhiệm vụ tháng Chín", "Nhiệm vụ hằng ngày").
///
/// Nằm cùng file với [Quest] vì nó chỉ là một danh sách [Quest] có tiêu đề —
/// quan hệ bộ phận, không phải khái niệm độc lập.
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
