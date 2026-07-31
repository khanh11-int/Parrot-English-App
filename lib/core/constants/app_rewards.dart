/// Mức thưởng và lịch ôn của thuật toán SRS.
///
/// Gom một chỗ vì hai nơi cùng cần: `SessionProgress` để hiện số ở trang tổng
/// kết, và `FirebaseVocabularyRepository` để ghi vào Firestore. Trước đây mỗi
/// nơi khai một bản, sửa một bên là hai con số lệch nhau ngay.
abstract final class AppRewards {
  /// Thưởng cho mỗi câu trả lời đúng.
  static const experiencePerCorrectAnswer = 10;
  static const seedsPerCorrectAnswer = 2;

  /// Khoảng lặp lại của SRS, tính bằng ngày.
  ///
  /// Mốc đầu là **0 ngày** — từ vừa học xong đến hạn ôn lại **ngay trong ngày**.
  /// Nếu bắt đầu từ 1 ngày thì học xong hôm nay phải đợi tới mai mới ôn được,
  /// mà lúc đó người học đã quên mất phần vừa học.
  static const reviewIntervalDays = [0, 1, 3, 7, 21, 60];

  /// Từ có khoảng lặp lại từ mức này trở lên coi là đã thuộc.
  static const masteredIntervalDays = 21;

  /// Khoảng lặp lại kế tiếp sau một câu trả lời.
  ///
  /// - Lần đầu gặp từ → mốc đầu (0 ngày), cần củng cố ngay trong ngày.
  /// - Trả lời sai → về mốc đầu, từ chưa thuộc phải gặp lại sớm.
  /// - Trả lời đúng → nhảy sang mốc tiếp theo.
  static int nextIntervalDays({
    required int currentDays,
    required bool isCorrect,
    required bool isFirstTime,
  }) {
    if (isFirstTime || !isCorrect) return reviewIntervalDays.first;

    final index = reviewIntervalDays.indexOf(currentDays);
    if (index == -1) return reviewIntervalDays.first;
    return reviewIntervalDays[(index + 1).clamp(
      0,
      reviewIntervalDays.length - 1,
    )];
  }
}
