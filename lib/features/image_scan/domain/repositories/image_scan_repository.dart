import '../entities/recognized_word.dart';

/// Nguồn dữ liệu cho luồng nhận diện ảnh → sinh từ vựng.
abstract interface class ImageScanRepository {
  /// Gửi ảnh đi nhận diện và trả về kết quả khi xong.
  ///
  /// Cài đặt REST làm hai bước: `POST /scans` trả về id ngay, rồi hỏi lại
  /// `GET /scans/{id}` cho tới khi xử lý xong — vì gọi Vision AI có thể mất
  /// hàng chục giây, một request đồng bộ sẽ timeout.
  ///
  /// Ném `Failure` nếu thất bại.
  Future<ScanResult> recognize({String? imagePath});
}
