import '../../domain/entities/recognized_word.dart';
import '../../domain/repositories/image_scan_repository.dart';

/// Dữ liệu mock, dùng khi chưa khai báo `PARROT_API_BASE_URL`.
///
/// Giữ lại để người làm UI không bị chặn khi backend chưa xong, và để test
/// widget chạy được mà không cần server.
class ImageScanMockRepository implements ImageScanRepository {
  const ImageScanMockRepository();

  /// Nhận diện chậm hơn tải dữ liệu thường — độ trễ mock để lâu hơn nhằm thấy
  /// rõ trạng thái chờ và nút Huỷ có hoạt động.
  static const _mockDelay = Duration(milliseconds: 1800);

  @override
  Future<ScanResult> recognize({String? imagePath}) async {
    await Future<void>.delayed(_mockDelay);

    return ScanResult(
      imagePath: imagePath,
      words: const [
        RecognizedWord(
          id: 'chair',
          english: 'chair',
          vietnamese: 'cái ghế',
          phonetic: '/tʃeə(r)/',
          confidence: 0.98,
          boundingBox: BoundingBox(
            left: 0.06,
            top: 0.42,
            width: 0.30,
            height: 0.46,
          ),
        ),
        RecognizedWord(
          id: 'laptop',
          english: 'laptop',
          vietnamese: 'máy tính xách tay',
          phonetic: '/ˈlæptɒp/',
          confidence: 0.92,
          boundingBox: BoundingBox(
            left: 0.44,
            top: 0.38,
            width: 0.26,
            height: 0.18,
          ),
        ),
        RecognizedWord(
          id: 'desk',
          english: 'desk',
          vietnamese: 'bàn làm việc',
          phonetic: '/desk/',
          confidence: 0.89,
          boundingBox: BoundingBox(
            left: 0.30,
            top: 0.52,
            width: 0.62,
            height: 0.16,
          ),
        ),
        RecognizedWord(
          id: 'bookshelf',
          english: 'bookshelf',
          vietnamese: 'giá sách',
          phonetic: '/ˈbʊkʃelf/',
          confidence: 0.84,
          boundingBox: BoundingBox(
            left: 0.34,
            top: 0.08,
            width: 0.50,
            height: 0.30,
          ),
        ),
        RecognizedWord(
          id: 'lamp',
          english: 'lamp',
          vietnamese: 'đèn',
          phonetic: '/læmp/',
          confidence: 0.76,
          boundingBox: BoundingBox(
            left: 0.80,
            top: 0.30,
            width: 0.12,
            height: 0.22,
          ),
        ),
      ],
    );
  }
}
