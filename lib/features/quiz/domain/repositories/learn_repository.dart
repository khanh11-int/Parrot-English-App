import '../entities/learn_question.dart';

/// Nguồn nội dung phiên học và phiên ôn tập.
abstract interface class LearnRepository {
  /// Phiên học từ mới.
  ///
  /// [topicId] là `null` khi học trộn mọi chủ đề. Ném `Failure` nếu thất bại.
  Future<LearnSession> getLearnSession({String? topicId});

  /// Phiên ôn tập gồm các từ đã đến hạn theo SRS.
  ///
  /// [topicId] `null` là ôn trộn mọi chủ đề. Hết từ đến hạn thì lấy từ đã học
  /// để ôn lại — lịch SRS là gợi ý, không phải cái khoá.
  Future<LearnSession> getReviewSession({String? topicId});

  /// Gửi kết quả phiên lên server để cộng XP và cập nhật lịch ôn.
  Future<void> submitResult(String sessionId, SessionResult result);
}
