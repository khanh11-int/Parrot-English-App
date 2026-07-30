import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/shop_item.dart';

/// DTO của `GET /shop` và `POST /shop/purchases`. Xem `docs/API_SPEC.md`.
class ShopDataDto {
  const ShopDataDto({required this.wallet, required this.items});

  final WalletDto wallet;
  final List<ShopItemDto> items;

  factory ShopDataDto.fromJson(JsonMap json) {
    return ShopDataDto(
      wallet: WalletDto.fromJson(json.readObject('wallet')),
      items: json
          .readObjectList('items')
          .map(ShopItemDto.fromJson)
          .toList(growable: false),
    );
  }

  ShopData toEntity() => ShopData(
    wallet: wallet.toEntity(),
    items: items.map((item) => item.toEntity()).toList(growable: false),
  );
}

class WalletDto {
  const WalletDto({required this.seeds, required this.gems});

  final int seeds;
  final int gems;

  factory WalletDto.fromJson(JsonMap json) => WalletDto(
    seeds: json.readIntOr('seeds', 0),
    gems: json.readIntOr('gems', 0),
  );

  Wallet toEntity() => Wallet(seeds: seeds, gems: gems);
}

class ShopItemDto {
  const ShopItemDto({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.price,
    required this.currency,
    required this.ownedCount,
  });

  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int price;
  final String currency;
  final int ownedCount;

  factory ShopItemDto.fromJson(JsonMap json) {
    return ShopItemDto(
      id: json.readString('id'),
      name: json.readString('name'),
      description: json.readStringOrNull('description') ?? '',
      iconUrl: json.readStringOrNull('icon_url') ?? '',
      price: json.readIntOr('price', 0),
      currency: json.readString('currency'),
      ownedCount: json.readIntOr('owned_count', 0),
    );
  }

  ShopItem toEntity() => ShopItem(
    id: id,
    name: name,
    description: description,
    iconAsset: iconUrl,
    price: price,
    currency: parseCurrency(currency),
    ownedCount: ownedCount,
  );

  /// Loại tiền lạ được coi là `seed` thay vì làm sập cả trang: người dùng vẫn
  /// xem được cửa hàng, chỉ một vật phẩm hiện sai icon.
  static ShopCurrency parseCurrency(String raw) => switch (raw) {
    'gem' => ShopCurrency.gem,
    _ => ShopCurrency.seed,
  };
}
