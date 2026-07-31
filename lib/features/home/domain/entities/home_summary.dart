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
    required this.learnedWordCount,
    required this.totalWordCount,
    required this.dailyQuests,
  });

  /// Tên người dùng, để trang chủ chào đúng tên.
  final String userName;
  final int streakDays;
  final int gemCount;
  final int seedCount;

  /// Số từ đã học trên tổng số từ của giáo trình — thẻ "Hành trình".
  ///
  /// Trước đây hai số này bị nhồi vào **chuỗi tiêu đề** của một `Quest`
  /// ("Học hết 56 từ trong giáo trình"), nên UI không thể hiện `16/56` mà chỉ
  /// hiện được `%`.
  final int learnedWordCount;
  final int totalWordCount;

  final QuestGroup dailyQuests;

  /// Tỉ lệ hoàn thành giáo trình, 0..1.
  double get curriculumProgress => totalWordCount <= 0
      ? 0
      : (learnedWordCount / totalWordCount).clamp(0.0, 1.0);

  int get curriculumPercent => (curriculumProgress * 100).round();
}
