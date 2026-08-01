import 'quest.dart';

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
  /// Trước đây hai số này bị nhồi vào **chuỗi tiêu đề** của một [Quest]
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
