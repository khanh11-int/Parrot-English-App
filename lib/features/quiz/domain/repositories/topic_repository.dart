import '../entities/vocabulary_topic.dart';

/// Nguồn danh sách chủ đề kèm tiến độ học.
///
/// Tách khỏi `LearnRepository` vì hai việc khác nhau: đây là **danh mục chủ đề**
/// (dữ liệu dùng chung + tiến độ của người dùng), còn `LearnRepository` là
/// **sinh bài tập** từ các từ đã lưu.
abstract interface class TopicRepository {
  /// Mọi chủ đề, kèm số từ người dùng hiện tại đã học trong từng chủ đề.
  Future<List<VocabularyTopic>> getTopics();
}
