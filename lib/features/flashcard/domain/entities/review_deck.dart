/// Một bộ từ theo chủ đề, kèm số từ đã học / đã thuộc / đến hạn ôn.
class ReviewDeck {
  const ReviewDeck({
    required this.topicId,
    required this.topic,
    required this.totalCount,
    required this.learnedCount,
    required this.masteredCount,
    required this.dueCount,
    this.nextDueAt,
  });

  /// Id chủ đề, để mở phiên ôn riêng bộ từ này.
  final String topicId;

  final String topic;
  final int totalCount;

  /// Số từ đã học qua ít nhất một lần.
  ///
  /// Khác [masteredCount]: "đã thuộc" cần ôn đúng nhiều lần trong ba tuần, nên
  /// nếu chỉ hiện số đó thì bộ từ vừa học xong vẫn báo `0/8`, ngược hẳn với
  /// trang Học từ mới đang báo `8/8`.
  final int learnedCount;

  /// Số từ đã thuộc (khoảng lặp lại đã đủ dài theo SRS).
  final int masteredCount;

  /// Số từ đến hạn ôn hôm nay.
  final int dueCount;

  /// Thời điểm từ **kế tiếp** đến hạn, tính trong những từ chưa tới hạn.
  ///
  /// `null` khi bộ từ chưa học gì, hoặc khi mọi từ đã học đều đang đến hạn (lúc
  /// đó [dueCount] đã nói hết). Dùng để trả lời câu người học thật sự quan tâm:
  /// "bao giờ thì có cái để ôn?".
  final DateTime? nextDueAt;

  /// Còn từ đã học là còn ôn lại được, dù chưa tới hạn.
  bool get canReview => learnedCount > 0;

  /// Tỉ lệ đã học, 0..1. Chặn chia cho 0 khi bộ từ còn rỗng.
  double get learnedProgress =>
      totalCount <= 0 ? 0 : (learnedCount / totalCount).clamp(0.0, 1.0);

  /// Tỉ lệ thuộc, 0..1. Chặn chia cho 0 khi bộ từ còn rỗng.
  double get masteryProgress =>
      totalCount <= 0 ? 0 : (masteredCount / totalCount).clamp(0.0, 1.0);
}
