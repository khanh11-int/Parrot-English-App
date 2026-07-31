import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Một khe của thanh điều hướng dưới.
class BottomNavItem {
  const BottomNavItem({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}

/// Thanh điều hướng 4 khe chia đều.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  /// Chỉ số tab đang chọn.
  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const items = <BottomNavItem>[
    BottomNavItem(label: AppLabels.navHome, iconAsset: AppAssets.iconHome),
    BottomNavItem(label: AppLabels.navReview, iconAsset: AppAssets.iconStudy),
    BottomNavItem(
      label: AppLabels.navCommunity,
      iconAsset: AppAssets.iconMessage,
    ),
    BottomNavItem(
      label: AppLabels.navProfile,
      iconAsset: AppAssets.iconProfile,
    ),
  ];

  static const _barHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      height: _barHeight + bottomInset,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _NavSlot(
                item: items[i],
                isSelected: i == currentIndex,
                onTap: () => onSelected(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ảnh icon vốn là ảnh phẳng đơn sắc nên nhuộm được bằng color blend
          // để phân biệt tab đang chọn.
          Image.asset(
            item.iconAsset,
            width: 24,
            height: 24,
            color: color,
            colorBlendMode: BlendMode.srcIn,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
