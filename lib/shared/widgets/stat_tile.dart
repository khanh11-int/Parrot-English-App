import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Ô thống kê trong mục "Tổng quan" của trang cá nhân: icon + nhãn mờ + giá trị
/// đậm. Nhãn dài bị cắt bằng dấu `…` nên ô luôn giữ đúng chiều cao.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconAsset,
    this.iconColor = AppColors.primary,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? iconAsset;
  final Color iconColor;
  final VoidCallback? onTap;

  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final asset = iconAsset;

    return Material(
      color: AppColors.bgBase,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (asset != null)
                Image.asset(asset, width: _iconSize, height: _iconSize)
              else
                Icon(icon, size: _iconSize, color: iconColor),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      value,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
