/// Loại tiền dùng để mua vật phẩm.
enum ShopCurrency { seed, gem }

/// Một vật phẩm trong Cửa hàng.
class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.price,
    required this.currency,
    this.ownedCount = 0,
  });

  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final int price;
  final ShopCurrency currency;

  /// Số lượng người dùng đang có, dùng cho mục "Vật phẩm của tôi".
  final int ownedCount;

  bool get isOwned => ownedCount > 0;

  ShopItem copyWith({int? ownedCount}) {
    return ShopItem(
      id: id,
      name: name,
      description: description,
      iconAsset: iconAsset,
      price: price,
      currency: currency,
      ownedCount: ownedCount ?? this.ownedCount,
    );
  }
}

/// Số dư hai loại tiền của người dùng.
class Wallet {
  const Wallet({required this.seeds, required this.gems});

  final int seeds;
  final int gems;

  int amountOf(ShopCurrency currency) => switch (currency) {
    ShopCurrency.seed => seeds,
    ShopCurrency.gem => gems,
  };

  bool canAfford(ShopItem item) => amountOf(item.currency) >= item.price;

  Wallet spend(ShopItem item) => switch (item.currency) {
    ShopCurrency.seed => Wallet(seeds: seeds - item.price, gems: gems),
    ShopCurrency.gem => Wallet(seeds: seeds, gems: gems - item.price),
  };
}

/// Toàn bộ dữ liệu của Cửa hàng.
class ShopData {
  const ShopData({required this.wallet, required this.items});

  final Wallet wallet;
  final List<ShopItem> items;

  List<ShopItem> get ownedItems => items.where((item) => item.isOwned).toList();
}
