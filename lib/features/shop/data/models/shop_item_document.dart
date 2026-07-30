import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/shop_item.dart';

/// Ánh xạ document Firestore `shopItems/{itemId}`.
///
/// Số lượng người dùng đang có **không** nằm ở đây mà ở
/// `users/{uid}/inventory/{itemId}` — mỗi người một con số khác nhau.
class ShopItemDocument {
  const ShopItemDocument({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.order,
  });

  static const collection = 'shopItems';

  /// Subcollection lưu vật phẩm người dùng đang có.
  static const inventoryCollection = 'inventory';

  final String id;
  final String name;
  final String description;
  final int price;
  final ShopCurrency currency;
  final int order;

  factory ShopItemDocument.fromMap(String id, Map<String, dynamic> map) {
    // `trim()` vì dữ liệu nhập tay qua Console rất dễ dính khoảng trắng hoặc
    // tab ở đầu/cuối khi copy-paste.
    String? trimmed(Object? value) => value is String ? value.trim() : null;

    final rawName = trimmed(map['name']);
    final rawDescription = trimmed(map['description']);
    final rawPrice = map['price'];
    final rawOrder = map['order'];

    return ShopItemDocument(
      id: id,
      name: rawName is String && rawName.isNotEmpty ? rawName : id,
      description: rawDescription is String ? rawDescription : '',
      price: rawPrice is num ? rawPrice.toInt() : 0,
      currency: _parseCurrency(trimmed(map['currency'])),
      order: rawOrder is num ? rawOrder.toInt() : 0,
    );
  }

  ShopItem toEntity({required int ownedCount}) => ShopItem(
    id: id,
    name: name,
    description: description,
    iconAsset: iconAssetFor(id),
    price: price,
    currency: currency,
    ownedCount: ownedCount,
  );

  /// Loại tiền lạ hoặc thiếu được coi là `seed` thay vì làm sập cả trang.
  static ShopCurrency _parseCurrency(Object? raw) =>
      raw == 'gem' ? ShopCurrency.gem : ShopCurrency.seed;

  /// Ảnh vật phẩm lấy từ asset trong app theo id, không lưu URL trên Firestore.
  static String iconAssetFor(String itemId) {
    return switch (itemId) {
      'boost-fruit' => AppAssets.itemEnergy,
      'bark-shield' => AppAssets.itemShield,
      'nectar-bottle' => AppAssets.itemGift,
      'sticker-pack' => AppAssets.stickerHappy,
      'league-ticket' => AppAssets.itemTicket,
      _ => AppAssets.itemTarget,
    };
  }
}
