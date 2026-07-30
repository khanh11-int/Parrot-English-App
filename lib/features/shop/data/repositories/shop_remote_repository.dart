import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/shop_item.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_dtos.dart';

/// Cửa hàng lấy dữ liệu từ REST API.
class ShopRemoteRepository implements ShopRepository {
  const ShopRemoteRepository(this._client);

  final ApiClient _client;

  @override
  Future<ShopData> getShopData() async {
    final json = await _client.getObject(ApiEndpoints.shop);
    return ShopDataDto.fromJson(json).toEntity();
  }

  @override
  Future<ShopData> purchase(String itemId) async {
    final json = await _client.post(
      ApiEndpoints.purchases,
      body: {'item_id': itemId},
    );
    return ShopDataDto.fromJson(json).toEntity();
  }
}
