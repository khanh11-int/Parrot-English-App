import 'word_pair.dart';

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
///
/// Cả cây thừa kế **buộc phải** nằm trong một file: Dart chỉ cho `sealed class`
/// có lớp con trong cùng library. Đổi lại, `switch` trên [Exercise] được kiểm
/// đủ nhánh lúc biên dịch — thêm dạng bài mới mà quên xử lý là lỗi ngay.
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
