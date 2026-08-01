import 'shop_item.dart';

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
