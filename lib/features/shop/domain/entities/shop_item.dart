/// Loại tiền dùng để mua vật phẩm.
///
/// Nằm cùng file với [ShopItem] vì nó chỉ tồn tại để phân loại giá của vật
/// phẩm; tách riêng thì mở file ra chỉ thấy một dòng `enum`.
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
