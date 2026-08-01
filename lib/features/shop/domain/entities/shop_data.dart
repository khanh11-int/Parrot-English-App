import 'shop_item.dart';
import 'wallet.dart';

/// Toàn bộ dữ liệu của Cửa hàng: số dư + danh sách vật phẩm.
class ShopData {
  const ShopData({required this.wallet, required this.items});

  final Wallet wallet;
  final List<ShopItem> items;

  List<ShopItem> get ownedItems => items.where((item) => item.isOwned).toList();
}
