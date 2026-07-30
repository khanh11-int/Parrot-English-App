import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Ba loại số đếm hiện ở header trang chủ và Cửa hàng.
enum CurrencyKind {
  /// Chuỗi ngày học liên tiếp.
  streak(color: AppColors.streak, icon: Icons.local_fire_department_rounded),

  /// Tiền cứng.
  gem(color: AppColors.coinGem, asset: AppAssets.itemDiamond),

  /// Tiền mềm, kiếm bằng học tập.
  seed(color: AppColors.coinSeed, asset: AppAssets.itemCoin);

  const CurrencyKind({required this.color, this.asset, this.icon});

  final Color color;

  /// Ảnh trong `assets/` — ưu tiên dùng nếu có.
  final String? asset;

  /// Icon dự phòng khi chưa có ảnh riêng.
  final IconData? icon;
}

/// Chip viên thuốc: icon + số. Ví dụ `🔥 5`, `💎 2`, `🌰 15`.
class CurrencyPill extends StatelessWidget {
  const CurrencyPill({
    super.key,
    required this.kind,
    required this.amount,
    this.onTap,
  });

  final CurrencyKind kind;
  final int amount;
  final VoidCallback? onTap;

  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final asset = kind.asset;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.chipBorder,
      child: Padding(
        // Bảo đảm vùng bấm đủ 44px chiều cao dù nội dung nhỏ.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (asset != null)
              Image.asset(asset, width: _iconSize, height: _iconSize)
            else
              Icon(kind.icon, size: _iconSize, color: kind.color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '$amount',
              style: AppTextStyles.bodyBold.copyWith(color: kind.color),
            ),
          ],
        ),
      ),
    );
  }
}
