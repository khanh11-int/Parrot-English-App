/// Một từ đã lưu vào bộ từ của người dùng.
class SavedWord {
  const SavedWord({
    required this.id,
    required this.english,
    required this.vietnamese,
    required this.phonetic,
    this.topicId,
    this.reviewIntervalDays = 0,
    this.dueAt,
  });

  /// Id document, sinh từ chữ tiếng Anh nên lưu cùng một từ hai lần sẽ ghi đè
  /// chứ không tạo bản trùng.
  final String id;
  final String english;
  final String vietnamese;
  final String phonetic;

  /// Chủ đề người dùng gán cho từ; `null` là chưa phân loại.
  final String? topicId;

  /// Khoảng lặp lại hiện tại của thuật toán SRS, tính bằng ngày.
  final int reviewIntervalDays;

  /// Thời điểm đến hạn ôn; `null` là chưa từng ôn nên đến hạn ngay.
  final DateTime? dueAt;

  /// Từ đã thuộc khi khoảng lặp lại đủ dài.
  bool get isMastered => reviewIntervalDays >= masteredIntervalDays;

  /// Từ đến hạn ôn tại thời điểm [now].
  bool isDue(DateTime now) => dueAt == null || !dueAt!.isAfter(now);

  /// Từ mức này trở lên coi là đã thuộc.
  static const masteredIntervalDays = 21;

  /// Sinh id từ chữ tiếng Anh: chữ thường, chỉ giữ chữ và số, nối bằng `-`.
  static String idFrom(String english) {
    final slug = english
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp('^-+|-+\$'), '');
    // Từ không có ký tự latin nào (ví dụ chỉ có dấu) vẫn phải ra id dùng được.
    return slug.isEmpty ? 'tu-${english.hashCode.abs()}' : slug;
  }

  SavedWord copyWith({
    String? topicId,
    int? reviewIntervalDays,
    DateTime? dueAt,
  }) {
    return SavedWord(
      id: id,
      english: english,
      vietnamese: vietnamese,
      phonetic: phonetic,
      topicId: topicId ?? this.topicId,
      reviewIntervalDays: reviewIntervalDays ?? this.reviewIntervalDays,
      dueAt: dueAt ?? this.dueAt,
    );
  }
}
