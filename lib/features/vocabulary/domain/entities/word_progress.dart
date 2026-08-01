import '../../../../core/constants/app_rewards.dart';
import 'topic_word.dart';

/// Tiến độ học của người dùng với **một từ trong giáo trình**.
///
/// Lưu kèm chữ tiếng Anh / nghĩa (dữ liệu lặp so với [TopicWord]) để phiên ôn
/// tập chỉ cần một truy vấn: đọc các từ đến hạn là có luôn nội dung, không phải
/// đi tìm lại trong từng chủ đề.
class WordProgress {
  const WordProgress({
    required this.wordId,
    required this.topicId,
    required this.english,
    required this.vietnamese,
    required this.phonetic,
    this.reviewIntervalDays = 0,
    this.dueAt,
  });

  final String wordId;
  final String topicId;
  final String english;
  final String vietnamese;
  final String phonetic;

  /// Khoảng lặp lại hiện tại của thuật toán SRS, tính bằng ngày.
  final int reviewIntervalDays;

  /// Thời điểm đến hạn ôn; `null` là đến hạn ngay.
  final DateTime? dueAt;

  /// Từ đã thuộc khi khoảng lặp lại đủ dài.
  bool get isMastered => reviewIntervalDays >= masteredIntervalDays;

  bool isDue(DateTime now) => dueAt == null || !dueAt!.isAfter(now);

  /// Từ mức này trở lên coi là đã thuộc.
  static const masteredIntervalDays = AppRewards.masteredIntervalDays;

  /// Tiến độ khởi tạo khi người dùng học từ này lần đầu.
  factory WordProgress.startedFrom(TopicWord word) {
    return WordProgress(
      wordId: word.id,
      topicId: word.topicId,
      english: word.english,
      vietnamese: word.vietnamese,
      phonetic: word.phonetic,
    );
  }
}
