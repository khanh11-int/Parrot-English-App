import '../entities/home_summary.dart';

/// Nguồn dữ liệu trang chủ.
///
/// Interface nằm ở `domain/` nên `presentation/` không biết dữ liệu đến từ REST
/// hay từ mock; đổi cài đặt không phải sửa UI.
abstract interface class HomeRepository {
  /// Toàn bộ dữ liệu cần để vẽ trang chủ.
  ///
  /// Ném [Failure] nếu không lấy được.
  Future<HomeSummary> getSummary();
}
