import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/shop_data.dart';
import '../../domain/entities/shop_item.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/shop_repository.dart';

/// Dữ liệu mock, dùng khi chưa khai báo `PARROT_API_BASE_URL`.
///
/// Giữ lại để người làm UI không bị chặn khi backend chưa xong, và để test
/// widget chạy được mà không cần server.
class ShopMockRepository implements ShopRepository {
  const ShopMockRepository();

  static const _mockDelay = Duration(milliseconds: 450);

  /// Bản mock không có server để trừ tiền, nên tự tính lại ví và số lượng vật
  /// phẩm ngay trên dữ liệu vừa lấy được.
  @override
  Future<ShopData> purchase(String itemId) async {
    await Future<void>.delayed(_mockDelay);

    final data = await getShopData();
    final item = data.items.where((i) => i.id == itemId).firstOrNull;
    if (item == null || !data.wallet.canAfford(item)) return data;

    return ShopData(
      wallet: data.wallet.spend(item),
      items: [
        for (final current in data.items)
          if (current.id == itemId)
            current.copyWith(ownedCount: current.ownedCount + 1)
          else
            current,
      ],
    );
  }

  @override
  Future<ShopData> getShopData() async {
    await Future<void>.delayed(_mockDelay);

    return const ShopData(
      wallet: Wallet(seeds: 150, gems: 2),
      items: [
        ShopItem(
          id: 'boost-fruit',
          name: 'Quả Tăng Tốc',
          description: 'Nhân đôi XP nhận được trong 15 phút',
          iconAsset: AppAssets.itemBoostFruit,
          price: 150,
          currency: ShopCurrency.seed,
          ownedCount: 1,
        ),
        ShopItem(
          id: 'bark-shield',
          name: 'Khiên Vỏ Cây',
          description: 'Giữ chuỗi streak khi nghỉ 1 ngày',
          iconAsset: AppAssets.itemBarkShield,
          price: 200,
          currency: ShopCurrency.seed,
        ),
      ],
    );
  }
}
