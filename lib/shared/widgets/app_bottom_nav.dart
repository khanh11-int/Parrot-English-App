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

/// Thanh điều hướng 5 khe, khe giữa là nút camera nổi.
///
/// Nút camera không phải một tab (không giữ trạng thái chọn) mà mở luồng nhận
/// diện ảnh dạng toàn màn hình — đây là tính năng cốt lõi nên được đặt ở vị trí
/// dễ bấm nhất.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.onScanPressed,
  });

  /// Chỉ số tab đang chọn trong 4 tab (không tính nút camera).
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onScanPressed;

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
  static const _fabSize = 56.0;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SizedBox(
      // Chừa chỗ cho nửa trên của FAB nhô ra khỏi thanh nav.
      height: _barHeight + bottomInset + _fabSize / 2,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: _barHeight + bottomInset,
            decoration: const BoxDecoration(
              color: AppColors.bgBase,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  // Khe trống ở giữa dành cho FAB.
                  if (i == items.length ~/ 2)
                    const SizedBox(width: _fabSize + AppSpacing.lg),
                  Expanded(
                    child: _NavSlot(
                      item: items[i],
                      isSelected: i == currentIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: bottomInset + _barHeight - _fabSize / 2 - 4,
            child: _ScanFab(onPressed: onScanPressed),
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

class _ScanFab extends StatelessWidget {
  const _ScanFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppBottomNav._fabSize,
      height: AppBottomNav._fabSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: 'Chụp ảnh học từ mới',
        child: const Icon(Icons.photo_camera_rounded, size: 26),
      ),
    );
  }
}
