import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/saved_word.dart';
import '../../domain/entities/topic_word.dart';

/// Ánh xạ `topics/{topicId}/words/{wordId}` — giáo trình dùng chung.
abstract final class TopicWordDocument {
  static const collection = 'words';

  static TopicWord toEntity(
    String id,
    String topicId,
    Map<String, dynamic> map,
  ) {
    final rawOrder = map['order'];
    return TopicWord(
      id: id,
      topicId: topicId,
      english: _readString(map['english']),
      vietnamese: _readString(map['vietnamese']),
      phonetic: _readString(map['phonetic']),
      order: rawOrder is num ? rawOrder.toInt() : 0,
    );
  }

  static String _readString(Object? value) =>
      value is String ? value.trim() : '';
}

/// Ánh xạ `users/{uid}/wordProgress/{wordId}` — tiến độ học của người dùng.
abstract final class WordProgressDocument {
  static const collection = 'wordProgress';

  static WordProgress toEntity(String wordId, Map<String, dynamic> map) {
    final rawInterval = map['reviewIntervalDays'];
    final rawDueAt = map['dueAt'];

    return WordProgress(
      wordId: wordId,
      topicId: _readString(map['topicId']),
      english: _readString(map['english']),
      vietnamese: _readString(map['vietnamese']),
      phonetic: _readString(map['phonetic']),
      reviewIntervalDays: rawInterval is num ? rawInterval.toInt() : 0,
      dueAt: rawDueAt is Timestamp ? rawDueAt.toDate() : null,
    );
  }

  /// Dữ liệu ghi khi người dùng trả lời một từ.
  ///
  /// Ghi kèm chữ và nghĩa để phiên ôn tập đọc được nội dung từ chỉ bằng một
  /// truy vấn, không phải tra lại trong giáo trình từng chủ đề.
  static Map<String, dynamic> toMap({
    required TopicWord word,
    required int reviewIntervalDays,
    required DateTime dueAt,
  }) => {
    'topicId': word.topicId,
    'english': word.english,
    'vietnamese': word.vietnamese,
    'phonetic': word.phonetic,
    'reviewIntervalDays': reviewIntervalDays,
    'dueAt': Timestamp.fromDate(dueAt),
  };

  static String _readString(Object? value) =>
      value is String ? value.trim() : '';
}

/// Ánh xạ `users/{uid}/savedWords/{wordId}` — bộ từ lưu từ ảnh chụp.
abstract final class SavedWordDocument {
  static const collection = 'savedWords';

  static SavedWord toEntity(String id, Map<String, dynamic> map) {
    final rawTopicId = map['topicId'];
    return SavedWord(
      id: id,
      english: _readString(map['english']),
      vietnamese: _readString(map['vietnamese']),
      phonetic: _readString(map['phonetic']),
      topicId: rawTopicId is String && rawTopicId.isNotEmpty
          ? rawTopicId
          : null,
    );
  }

  static Map<String, dynamic> toMap(SavedWord word) => {
    'english': word.english.trim(),
    'vietnamese': word.vietnamese.trim(),
    'phonetic': word.phonetic.trim(),
    'topicId': word.topicId,
    'savedAt': FieldValue.serverTimestamp(),
  };

  static String _readString(Object? value) =>
      value is String ? value.trim() : '';
}
