import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/shop_item.dart';
import '../../../../shared/widgets/app_image.dart';

/// Một dòng vật phẩm: icon · tên + mô tả · giá kèm icon tiền.
class ShopItemRow extends StatelessWidget {
  const ShopItemRow({super.key, required this.item, required this.onTap});

  final ShopItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          children: [
            AppImage(source: item.iconAsset, width: 40, height: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            PriceTag(price: item.price, currency: item.currency),
          ],
        ),
      ),
    );
  }
}

/// Giá kèm icon loại tiền.
class PriceTag extends StatelessWidget {
  const PriceTag({super.key, required this.price, required this.currency});

  final int price;
  final ShopCurrency currency;

  @override
  Widget build(BuildContext context) {
    final (asset, color) = switch (currency) {
      ShopCurrency.seed => (AppAssets.itemCoin, AppColors.coinSeed),
      ShopCurrency.gem => (AppAssets.itemDiamond, AppColors.coinGem),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(asset, width: 20, height: 20),
        const SizedBox(width: AppSpacing.xs),
        Text('$price', style: AppTextStyles.bodyBold.copyWith(color: color)),
      ],
    );
  }
}
