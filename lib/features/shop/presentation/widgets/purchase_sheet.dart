import 'package:flutter/material.dart';

import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/shop_item.dart';
import 'shop_item_row.dart';

/// Bottom sheet xác nhận mua vật phẩm.
///
/// Trả về `true` nếu người dùng bấm Mua.
Future<bool?> showPurchaseSheet(
  BuildContext context, {
  required ShopItem item,
  required bool canAfford,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => _PurchaseSheet(item: item, canAfford: canAfford),
  );
}

class _PurchaseSheet extends StatelessWidget {
  const _PurchaseSheet({required this.item, required this.canAfford});

  final ShopItem item;
  final bool canAfford;

  @override
  Widget build(BuildContext context) {
    final currencyName = item.currency == ShopCurrency.seed
        ? AppLabels.seed.toLowerCase()
        : AppLabels.gem.toLowerCase();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(source: item.iconAsset, width: 72, height: 72),
            const SizedBox(height: AppSpacing.md),
            Text(item.name, style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: AppSpacing.lg),
            PriceTag(price: item.price, currency: item.currency),
            const SizedBox(height: AppSpacing.lg),
            // Nêu rõ lý do không mua được, thay vì để nút xám mà không giải
            // thích gì.
            if (!canAfford)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  'Không đủ $currencyName',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            PrimaryButton(
              label: 'Mua',
              onPressed: canAfford
                  ? () => Navigator.of(context).pop(true)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
