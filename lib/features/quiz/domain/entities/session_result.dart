/// Kết quả sau khi hoàn thành phiên học.
class SessionResult {
  const SessionResult({
    required this.learnedWordCount,
    required this.correctCount,
    required this.wrongCount,
    required this.earnedExperience,
    required this.earnedSeeds,
  });

  final int learnedWordCount;
  final int correctCount;
  final int wrongCount;
  final int earnedExperience;
  final int earnedSeeds;

  int get totalAnswers => correctCount + wrongCount;

  /// Tỉ lệ đúng, 0..1. Trả 0 khi chưa trả lời câu nào để tránh chia cho 0.
  double get accuracy => totalAnswers == 0 ? 0 : correctCount / totalAnswers;
}
