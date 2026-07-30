import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Hai kiểu màu cho thẻ hành động: việc chính (học từ mới) nổi hơn việc phụ
/// (ôn tập), để mắt biết nên bấm cái nào trước.
enum GoalCardStyle {
  primary(
    background: AppColors.primary,
    foreground: AppColors.textOnPrimary,
    border: AppColors.primary,
  ),
  leaf(
    background: AppColors.bgBase,
    foreground: AppColors.textPrimary,
    border: AppColors.divider,
  );

  const GoalCardStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

/// Thẻ hành động ở trang chủ: mascot ở trên, tên hành động ở dưới.
///
/// Cố tình **không** hiện tiến độ ở đây. Trang chủ chỉ cần trả lời "bấm vào đâu
/// để học"; con số chi tiết đã có ở trang chọn chủ đề, nhắc lại ở đây làm thẻ
/// rối mà không giúp người dùng quyết định nhanh hơn.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.label,
    required this.mascotAsset,
    required this.style,
    required this.onTap,
  });

  final String label;
  final String mascotAsset;
  final GoalCardStyle style;
  final VoidCallback onTap;

  static const _mascotSize = 64.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: style.background,
      borderRadius: AppRadius.cardLargeBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardLargeBorder,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardLargeBorder,
            border: Border.all(color: style.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                mascotAsset,
                height: _mascotSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyBold.copyWith(color: style.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
