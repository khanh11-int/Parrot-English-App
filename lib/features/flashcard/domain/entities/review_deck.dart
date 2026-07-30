/// Một bộ từ theo chủ đề, kèm số từ đã thuộc và số từ đến hạn ôn.
class ReviewDeck {
  const ReviewDeck({
    required this.topic,
    required this.totalCount,
    required this.masteredCount,
    required this.dueCount,
  });

  final String topic;
  final int totalCount;

  /// Số từ đã thuộc (khoảng lặp lại đã đủ dài theo SRS).
  final int masteredCount;

  /// Số từ đến hạn ôn hôm nay.
  final int dueCount;

  /// Tỉ lệ thuộc, 0..1. Chặn chia cho 0 khi bộ từ còn rỗng.
  double get masteryProgress =>
      totalCount <= 0 ? 0 : (masteredCount / totalCount).clamp(0.0, 1.0);
}
