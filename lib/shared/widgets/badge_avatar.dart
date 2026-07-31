import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Huy hiệu tròn (hạng cá nhân, mốc nhóm).
///
/// Chưa mở khoá thì ảnh bị làm xám và phủ dấu `?` — trạng thái khoá không được
/// thể hiện chỉ bằng màu, vì người dùng khó phân biệt màu sẽ không nhận ra.
class BadgeAvatar extends StatelessWidget {
  const BadgeAvatar({
    super.key,
    required this.asset,
    this.label,
    this.isUnlocked = true,
    this.isHighlighted = false,
    this.size = 64,
    this.onTap,
  });

  final String asset;

  /// Nhãn hiện dưới huy hiệu (tên hạng, tên mốc).
  final String? label;
  final bool isUnlocked;

  /// Huy hiệu đang ở hạng hiện tại → thêm viền xanh.
  final bool isHighlighted;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.chipBorder,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.leafLight : AppColors.neutral,
              shape: BoxShape.circle,
              border: isHighlighted
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            padding: EdgeInsets.all(size * 0.16),
            child: isUnlocked
                ? Image.asset(asset, fit: BoxFit.contain)
                : _LockedBadgeContent(asset: asset),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: size + AppSpacing.lg,
              child: Text(
                label!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  color: isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textDisabled,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ảnh huy hiệu mờ đi, kèm dấu `?` nhỏ ở góc dưới phải.
///
/// Hai lần chỉnh sau khi dựng ảnh thật ra xem:
/// - **Giữ màu gốc**, chỉ giảm độ mờ. Bản đầu làm xám hẳn rồi để độ mờ 0.35 nên
///   cái cây biến mất trên nền tròn xám nhạt.
/// - Dấu `?` **không** còn `FittedBox` phủ kín huy hiệu. Phủ kín thì che luôn cái
///   cây, mà mục đích của ảnh là cho người học thấy trước mình sắp trồng gì.
///
/// Trạng thái khoá vẫn không chỉ dựa vào màu — dấu `?` là dấu hiệu chính.
class _LockedBadgeContent extends StatelessWidget {
  const _LockedBadgeContent({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(opacity: 0.45, child: Image.asset(asset, fit: BoxFit.contain)),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '?',
              style: TextStyle(
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w700,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
