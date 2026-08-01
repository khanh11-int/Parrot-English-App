import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/user_data_revision.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_shop_repository.dart';
import '../../domain/entities/shop_data.dart';
import '../../domain/entities/shop_item.dart';
import '../../domain/repositories/shop_repository.dart';

/// Cửa hàng đọc từ Firestore.
///
/// Test override provider này bằng `ShopMockRepository`.
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return FirebaseShopRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

/// Kết quả một lần mua, để UI biết hiện thông báo gì.
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

class PurchaseSucceeded extends PurchaseOutcome {
  const PurchaseSucceeded();
}

class PurchaseFailed extends PurchaseOutcome {
  const PurchaseFailed(this.message);

  final String message;
}

/// Dữ liệu Cửa hàng + hành động mua.
class ShopController extends AsyncNotifier<ShopData> {
  @override
  Future<ShopData> build() {
    // Học xong được thưởng hạt: theo dõi bộ đếm để ví trong cửa hàng tự cập
    // nhật, không phải mở lại app mới thấy số mới.
    ref.watch(userDataRevisionProvider);
    return ref.read(shopRepositoryProvider).getShopData();
  }

  /// Mua một vật phẩm.
  ///
  /// Kiểm số dư ở client chỉ để chặn request chắc chắn thất bại. **Quyết định
  /// cuối cùng là của server** (transaction trong Firestore): số dư có thể đã
  /// đổi ở thiết bị khác.
  Future<PurchaseOutcome> buy(String itemId) async {
    final data = state.valueOrNull;
    if (data == null) return const PurchaseFailed('Chưa tải xong cửa hàng.');

    final item = data.items.where((i) => i.id == itemId).firstOrNull;
    if (item == null) return const PurchaseFailed('Vật phẩm không tồn tại.');

    if (!data.wallet.canAfford(item)) {
      final currency = item.currency == ShopCurrency.seed ? 'hạt' : 'ngọc';
      return PurchaseFailed('Không đủ $currency để mua ${item.name}.');
    }

    try {
      final updated = await ref.read(shopRepositoryProvider).purchase(itemId);
      state = AsyncData(updated);
      return const PurchaseSucceeded();
    } on Failure catch (failure) {
      return PurchaseFailed(failure.message);
    }
  }
}

final shopProvider = AsyncNotifierProvider<ShopController, ShopData>(
  ShopController.new,
);
