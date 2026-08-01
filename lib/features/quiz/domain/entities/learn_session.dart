import 'exercise.dart';

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
