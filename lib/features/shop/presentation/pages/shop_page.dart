import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/currency_pill.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/shop_item.dart';
import '../providers/shop_providers.dart';
import '../widgets/purchase_sheet.dart';
import '../widgets/shop_item_row.dart';

/// Cửa hàng — mục 5.7 của `UI_SPEC.md`.
class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cửa hàng'),
        actions: [
          if (shopAsync.valueOrNull case final data?) ...[
            CurrencyPill(kind: CurrencyKind.gem, amount: data.wallet.gems),
            CurrencyPill(kind: CurrencyKind.seed, amount: data.wallet.seeds),
            const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: shopAsync,
          onRetry: () => ref.invalidate(shopProvider),
          data: (data) => _ShopContent(data: data),
        ),
      ),
    );
  }
}

class _ShopContent extends ConsumerWidget {
  const _ShopContent({required this.data});

  final ShopData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownedItems = data.ownedItems;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.sm),
        const SectionHeader(title: 'Vật phẩm của tôi'),
        if (ownedItems.isEmpty)
          Text('Bạn chưa có vật phẩm nào.', style: AppTextStyles.caption)
        else
          _OwnedItemsRow(items: ownedItems),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Mua ngay'),
        _PurchasableList(data: data),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Dải ngang các vật phẩm đang có, kèm số lượng.
class _OwnedItemsRow extends StatelessWidget {
  const _OwnedItemsRow({required this.items});

  final List<ShopItem> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => _OwnedItemTile(item: items[index]),
      ),
    );
  }
}

class _OwnedItemTile extends StatelessWidget {
  const _OwnedItemTile({required this.item});

  final ShopItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.leafLight,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(source: item.iconAsset, width: 32, height: 32),
          const SizedBox(height: AppSpacing.xs),
          Text('×${item.ownedCount}', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _PurchasableList extends ConsumerWidget {
  const _PurchasableList({required this.data});

  final ShopData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Column(
        children: [
          for (final item in data.items) ...[
            ShopItemRow(
              item: item,
              onTap: () => _confirmPurchase(context, ref, item),
            ),
            if (item != data.items.last)
              const Divider(height: 1, indent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmPurchase(
    BuildContext context,
    WidgetRef ref,
    ShopItem item,
  ) async {
    final shouldBuy = await showPurchaseSheet(
      context,
      item: item,
      canAfford: data.wallet.canAfford(item),
    );
    if (shouldBuy != true || !context.mounted) return;

    final outcome = await ref.read(shopProvider.notifier).buy(item.id);
    // Mua là lời gọi mạng nên phải kiểm `mounted` lại sau `await`.
    if (!context.mounted) return;

    final message = switch (outcome) {
      PurchaseSucceeded() => 'Đã mua ${item.name}.',
      PurchaseFailed(:final message) => message,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: AppDurations.snackBar),
      );
  }
}
