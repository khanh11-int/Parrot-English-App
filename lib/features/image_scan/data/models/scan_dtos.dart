import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/recognized_word.dart';

/// Trạng thái xử lý của một lần nhận diện.
enum ScanStatus {
  /// Đang xếp hàng hoặc đang gọi Vision AI.
  processing,

  /// Đã có kết quả.
  completed,

  /// Xử lý thất bại ở phía server.
  failed;

  static ScanStatus fromJson(String raw) => switch (raw) {
    'completed' => ScanStatus.completed,
    'failed' => ScanStatus.failed,
    // Mọi trạng thái khác (`queued`, `processing`, ...) đều là "chưa xong" →
    // client cứ tiếp tục hỏi lại.
    _ => ScanStatus.processing,
  };
}

/// DTO của `POST /scans` và `GET /scans/{id}`. Xem `docs/API_SPEC.md`.
class ScanResultDto {
  const ScanResultDto({
    required this.id,
    required this.status,
    required this.words,
    this.imageUrl,
    this.errorMessage,
  });

  final String id;
  final ScanStatus status;
  final List<RecognizedWordDto> words;

  /// URL ảnh đã lưu trên server, dùng để hiển thị lại về sau.
  final String? imageUrl;
  final String? errorMessage;

  factory ScanResultDto.fromJson(JsonMap json) {
    return ScanResultDto(
      id: json.readString('id'),
      status: ScanStatus.fromJson(json.readStringOrNull('status') ?? ''),
      imageUrl: json.readStringOrNull('image_url'),
      errorMessage: json.readStringOrNull('error_message'),
      // Lúc còn đang xử lý thì chưa có `words`.
      words: json['words'] == null
          ? const []
          : json
                .readObjectList('words')
                .map(RecognizedWordDto.fromJson)
                .toList(growable: false),
    );
  }

  ScanResult toEntity({String? localImagePath}) => ScanResult(
    // Ưu tiên ảnh local: hiện ngay được, không phải chờ tải ảnh từ mạng.
    imagePath: localImagePath ?? imageUrl,
    words: words.map((word) => word.toEntity()).toList(growable: false),
  );
}

class RecognizedWordDto {
  const RecognizedWordDto({
    required this.id,
    required this.english,
    required this.vietnamese,
    required this.phonetic,
    required this.confidence,
    required this.boundingBox,
  });

  final String id;
  final String english;
  final String vietnamese;
  final String phonetic;
  final double confidence;
  final BoundingBoxDto boundingBox;

  factory RecognizedWordDto.fromJson(JsonMap json) {
    return RecognizedWordDto(
      id: json.readString('id'),
      english: json.readString('english'),
      vietnamese: json.readString('vietnamese'),
      phonetic: json.readStringOrNull('phonetic') ?? '',
      confidence: json.readDouble('confidence'),
      boundingBox: BoundingBoxDto.fromJson(json.readObject('bounding_box')),
    );
  }

  RecognizedWord toEntity() => RecognizedWord(
    id: id,
    english: english,
    vietnamese: vietnamese,
    phonetic: phonetic,
    confidence: confidence,
    boundingBox: boundingBox.toEntity(),
  );
}

/// Khung bao vật thể, backend gửi theo **tỉ lệ 0..1** so với kích thước ảnh.
class BoundingBoxDto {
  const BoundingBoxDto({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;

  factory BoundingBoxDto.fromJson(JsonMap json) => BoundingBoxDto(
    left: json.readDouble('left'),
    top: json.readDouble('top'),
    width: json.readDouble('width'),
    height: json.readDouble('height'),
  );

  BoundingBox toEntity() =>
      BoundingBox(left: left, top: top, width: width, height: height);
}
