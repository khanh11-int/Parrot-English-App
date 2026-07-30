/// Khung bao quanh vật thể trong ảnh, lưu theo **tỉ lệ 0..1** so với kích thước
/// ảnh gốc.
///
/// Không lưu pixel tuyệt đối: cùng một kết quả nhận diện phải vẽ đúng dù ảnh
/// được hiển thị ở kích thước nào, trên máy nào.
class BoundingBox {
  const BoundingBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  /// Đổi sang pixel theo kích thước hiển thị thực tế của ảnh.
  ({double left, double top, double width, double height}) scaleTo(
    double displayWidth,
    double displayHeight,
  ) {
    return (
      left: left * displayWidth,
      top: top * displayHeight,
      width: width * displayWidth,
      height: height * displayHeight,
    );
  }
}

/// Một từ vựng do AI nhận ra trong ảnh.
class RecognizedWord {
  const RecognizedWord({
    required this.id,
    required this.english,
    required this.vietnamese,
    required this.phonetic,
    required this.confidence,
    required this.boundingBox,
    this.topicId,
    this.topicName,
  });

  final String id;
  final String english;
  final String vietnamese;

  /// Phiên âm IPA, ví dụ `/tʃeə(r)/`.
  final String phonetic;

  /// Độ tin cậy của AI, 0..1.
  final double confidence;
  final BoundingBox boundingBox;

  /// Id chủ đề người dùng gán cho từ; `null` là chưa chọn.
  ///
  /// Lưu **id** vì Firestore dùng id làm khoá của `topicProgress`.
  final String? topicId;

  /// Tên chủ đề để hiển thị.
  ///
  /// Lưu kèm thay vì tra lại từ id: danh sách chủ đề có thể chưa tải xong, khi
  /// đó chip sẽ hiện "chọn chủ đề" dù người dùng đã chọn rồi.
  final String? topicName;

  /// Nhãn hiện trên khung trong ảnh, ví dụ `chair 0.98`.
  String get overlayLabel => '$english ${confidence.toStringAsFixed(2)}';

  RecognizedWord copyWith({String? topicId, String? topicName}) {
    return RecognizedWord(
      id: id,
      english: english,
      vietnamese: vietnamese,
      phonetic: phonetic,
      confidence: confidence,
      boundingBox: boundingBox,
      topicId: topicId ?? this.topicId,
      topicName: topicName ?? this.topicName,
    );
  }
}

/// Kết quả một lần nhận diện ảnh.
class ScanResult {
  const ScanResult({required this.imagePath, required this.words});

  /// Đường dẫn ảnh đã chụp/chọn trên máy.
  ///
  /// `null` khi chạy bản mock (chưa có ảnh thật) — UI hiện khung ảnh giả để vẫn
  /// kiểm tra được phần vẽ khung nhận diện.
  final String? imagePath;
  final List<RecognizedWord> words;
}
