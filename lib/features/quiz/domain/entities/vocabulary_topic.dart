/// Một chủ đề từ vựng kèm tiến độ học.
class VocabularyTopic {
  const VocabularyTopic({
    required this.id,
    required this.name,
    required this.learnedCount,
    required this.totalCount,
    required this.iconAsset,
  });

  final String id;
  final String name;

  /// Số từ đã học trong chủ đề.
  final int learnedCount;
  final int totalCount;

  /// Ảnh minh hoạ chủ đề (URL khi chạy API thật, đường dẫn asset khi mock).
  final String iconAsset;

  /// Tỉ lệ đã học, 0..1. Chặn chia cho 0 khi chủ đề còn rỗng.
  double get progress =>
      totalCount <= 0 ? 0 : (learnedCount / totalCount).clamp(0.0, 1.0);

  int get percent => (progress * 100).round();

  /// Số từ chưa học.
  int get remainingCount => (totalCount - learnedCount).clamp(0, totalCount);

  bool get isCompleted => remainingCount == 0 && totalCount > 0;
}
