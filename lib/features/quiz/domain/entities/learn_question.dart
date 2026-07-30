/// Một cặp từ Anh–Việt, đơn vị nhỏ nhất của mọi dạng bài tập.
class WordPair {
  const WordPair({
    required this.id,
    required this.english,
    required this.vietnamese,
  });

  final String id;
  final String english;
  final String vietnamese;
}

/// Các dạng bài tập trong một phiên học.
enum ExerciseKind {
  /// Nối cặp từ Anh ↔ Việt.
  matchPairs('Nối các cặp từ'),

  /// Trắc nghiệm 4 đáp án.
  multipleChoice('Chọn nghĩa đúng');

  const ExerciseKind(this.instruction);

  /// Câu hướng dẫn hiện ở đầu bài.
  final String instruction;
}

/// Một vòng bài tập.
sealed class Exercise {
  const Exercise({required this.kind});

  final ExerciseKind kind;
}

/// Vòng nối cặp: người học ghép từng từ tiếng Anh với nghĩa tiếng Việt.
class MatchPairsExerciseData extends Exercise {
  const MatchPairsExerciseData({required this.pairs})
    : super(kind: ExerciseKind.matchPairs);

  final List<WordPair> pairs;
}

/// Vòng trắc nghiệm: một câu hỏi, 4 đáp án, đúng một đáp án.
class MultipleChoiceExerciseData extends Exercise {
  const MultipleChoiceExerciseData({
    required this.word,
    required this.options,
    required this.correctOption,
  }) : super(kind: ExerciseKind.multipleChoice);

  final WordPair word;

  /// 4 nghĩa tiếng Việt, đã xáo trộn.
  final List<String> options;
  final String correctOption;

  /// Câu hỏi hiện cho người học, ví dụ `'Diet' có nghĩa là gì?`.
  String get question => "'${word.english}' có nghĩa là gì?";
}

/// Một phiên học gồm nhiều vòng.
class LearnSession {
  const LearnSession({
    required this.id,
    required this.title,
    required this.exercises,
  });

  /// Id do server cấp, dùng khi gửi kết quả phiên lên.
  final String id;
  final String title;
  final List<Exercise> exercises;
}

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
