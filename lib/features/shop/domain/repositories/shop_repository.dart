import '../entities/shop_data.dart';

/// Nguồn dữ liệu Cửa hàng.
abstract interface class ShopRepository {
  /// Ví và danh sách vật phẩm. Ném `Failure` nếu thất bại.
  Future<ShopData> getShopData();

  /// Mua một vật phẩm, trả về trạng thái ví/vật phẩm **sau khi** mua.
  ///
  /// Server là nơi quyết định cuối cùng: client không được tự trừ tiền rồi tin
  /// là xong, vì số dư có thể đã đổi ở thiết bị khác.
  Future<ShopData> purchase(String itemId);
}
