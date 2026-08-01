/// Một từ trong **giáo trình** của chủ đề.
///
/// Dữ liệu dùng chung, admin soạn. Người dùng không thêm từ vào đây. Tiến độ học
/// của họ với từng từ nằm ở `WordProgress`, file riêng.
class TopicWord {
  const TopicWord({
    required this.id,
    required this.topicId,
    required this.english,
    required this.vietnamese,
    required this.phonetic,
    this.order = 0,
  });

  final String id;
  final String topicId;
  final String english;
  final String vietnamese;

  /// Phiên âm IPA, ví dụ `/tʃeə(r)/`.
  final String phonetic;

  /// Thứ tự trong giáo trình — dạy từ dễ tới khó.
  final int order;
}
