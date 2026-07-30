import '../../domain/entities/learn_question.dart';
import '../../domain/repositories/learn_repository.dart';

/// Dữ liệu mock, dùng khi chưa khai báo `PARROT_API_BASE_URL`.
///
/// Giữ lại để người làm UI không bị chặn khi backend chưa xong, và để test
/// widget chạy được mà không cần server.
class LearnMockRepository implements LearnRepository {
  const LearnMockRepository();

  static const _mockDelay = Duration(milliseconds: 400);

  // Khai báo từng từ thành hằng số riêng: truy cập theo chỉ số danh sách không
  // phải biểu thức `const` nên không dùng được trong dữ liệu mock bên dưới.
  static const _fatigue = WordPair(
    id: 'fatigue',
    english: 'Fatigue',
    vietnamese: 'Sự mệt mỏi',
  );
  static const _cough = WordPair(
    id: 'cough',
    english: 'Cough',
    vietnamese: 'Ho',
  );
  static const _grandfather = WordPair(
    id: 'grandfather',
    english: 'Grandfather',
    vietnamese: 'Ông',
  );
  static const _brother = WordPair(
    id: 'brother',
    english: 'Brother',
    vietnamese: 'Anh, em trai',
  );
  static const _diet = WordPair(
    id: 'diet',
    english: 'Diet',
    vietnamese: 'Chế độ ăn uống',
  );
  static const _depression = WordPair(
    id: 'depression',
    english: 'Depression',
    vietnamese: 'Trầm cảm',
  );
  static const _son = WordPair(
    id: 'son',
    english: 'Son',
    vietnamese: 'Con trai',
  );

  @override
  Future<LearnSession> getLearnSession({String? topicId}) async {
    await Future<void>.delayed(_mockDelay);

    return const LearnSession(
      id: 'mock-learn-session',
      title: 'Học từ mới',
      exercises: [
        MatchPairsExerciseData(
          pairs: [_fatigue, _cough, _grandfather, _brother],
        ),
        MultipleChoiceExerciseData(
          word: _diet,
          options: ['Chế độ ăn uống', 'Ông', 'Trầm cảm', 'Con trai'],
          correctOption: 'Chế độ ăn uống',
        ),
        MultipleChoiceExerciseData(
          word: _depression,
          options: ['Sự mệt mỏi', 'Trầm cảm', 'Ho', 'Anh, em trai'],
          correctOption: 'Trầm cảm',
        ),
      ],
    );
  }

  /// Phiên ôn tập: các từ đã đến hạn ôn theo thuật toán SRS.
  @override
  Future<LearnSession> getReviewSession() async {
    await Future<void>.delayed(_mockDelay);

    return const LearnSession(
      id: 'mock-review-session',
      title: 'Ôn tập',
      exercises: [
        MultipleChoiceExerciseData(
          word: _son,
          options: ['Con trai', 'Ông', 'Ho', 'Sự mệt mỏi'],
          correctOption: 'Con trai',
        ),
        MatchPairsExerciseData(pairs: [_diet, _depression, _cough, _fatigue]),
      ],
    );
  }

  /// Bản mock không có server để ghi nhận kết quả — bỏ qua một cách tường minh
  /// thay vì để hàm rỗng không rõ ý.
  @override
  Future<void> submitResult(String sessionId, SessionResult result) async {}
}
