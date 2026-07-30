import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/recognized_word.dart';
import '../../domain/repositories/image_scan_repository.dart';
import '../models/scan_dtos.dart';

/// Nhận diện ảnh qua REST API.
///
/// Không gọi thẳng Vision AI của nhà cung cấp: mọi thứ đi qua backend trung gian
/// của chúng ta, nơi giữ API key.
class ImageScanRemoteRepository implements ImageScanRepository {
  const ImageScanRemoteRepository(this._client);

  final ApiClient _client;

  /// Khoảng cách giữa hai lần hỏi lại kết quả.
  static const _pollInterval = Duration(seconds: 2);

  /// Số lần hỏi lại tối đa — chặn vòng lặp vô hạn khi server treo.
  /// 30 × 2s = tối đa 1 phút chờ.
  static const _maxPollAttempts = 30;

  @override
  Future<ScanResult> recognize({String? imagePath}) async {
    if (imagePath == null) {
      throw const ValidationFailure('Chưa chọn ảnh để nhận diện.');
    }

    final created = ScanResultDto.fromJson(
      await _client.uploadImage(ApiEndpoints.scans, filePath: imagePath),
    );

    // Server có thể trả kết quả ngay nếu ảnh xử lý nhanh.
    if (created.status == ScanStatus.completed) {
      return created.toEntity(localImagePath: imagePath);
    }
    if (created.status == ScanStatus.failed) {
      throw ServerFailure(created.errorMessage ?? 'Không đọc được ảnh.');
    }

    return _pollUntilDone(created.id, imagePath: imagePath);
  }

  Future<ScanResult> _pollUntilDone(
    String scanId, {
    required String imagePath,
  }) async {
    for (var attempt = 0; attempt < _maxPollAttempts; attempt++) {
      await Future<void>.delayed(_pollInterval);

      final result = ScanResultDto.fromJson(
        await _client.getObject(ApiEndpoints.scan(scanId)),
      );

      switch (result.status) {
        case ScanStatus.completed:
          return result.toEntity(localImagePath: imagePath);
        case ScanStatus.failed:
          throw ServerFailure(result.errorMessage ?? 'Không đọc được ảnh.');
        case ScanStatus.processing:
          continue;
      }
    }

    throw const TimeoutFailure('Nhận diện ảnh mất quá nhiều thời gian.');
  }
}
