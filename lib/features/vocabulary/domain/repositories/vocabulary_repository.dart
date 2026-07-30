import '../entities/saved_word.dart';
import '../entities/topic_word.dart';

/// Giáo trình từ vựng + tiến độ học của người dùng.
abstract interface class VocabularyRepository {
  /// Toàn bộ từ trong giáo trình của một chủ đề.
  Future<List<TopicWord>> getTopicWords(String topicId);

  /// Tiến độ học của người dùng.
  ///
  /// [topicId] `null` là lấy mọi chủ đề.
  Future<List<WordProgress>> getProgress({String? topicId});

  /// Các từ đã đến hạn ôn theo SRS, mọi chủ đề.
  Future<List<WordProgress>> getDueProgress({int limit = 50});

  /// Ghi nhận kết quả học/ôn một từ để dịch lịch ôn kế tiếp.
  ///
  /// Lần đầu gọi với một từ sẽ tạo tiến độ và tăng số từ đã học của chủ đề.
  Future<void> recordAnswer({required TopicWord word, required bool isCorrect});
}

/// Bộ từ người dùng tự lưu từ ảnh chụp.
///
/// Tách hẳn khỏi [VocabularyRepository]: đây là danh sách để xem lại, **không**
/// tham gia vào phần "Học từ mới" và không ảnh hưởng tiến độ chủ đề.
abstract interface class SavedWordRepository {
  Future<void> saveWords(List<SavedWord> words);

  Future<List<SavedWord>> getSavedWords({int limit = 100});

  Future<void> removeWord(String wordId);
}
