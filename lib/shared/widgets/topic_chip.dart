import 'package:flutter/material.dart';

import '../../core/constants/app_labels.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Chip chọn chủ đề cho một từ vựng.
///
/// Chưa chọn thì hiện "chọn chủ đề" (nền xanh nhạt), đã chọn thì hiện tên chủ
/// đề (nền xanh đậm) để phân biệt ngay bằng mắt.
class TopicChip extends StatelessWidget {
  const TopicChip({super.key, this.topic, required this.onTap});

  /// `null` nghĩa là chưa chọn chủ đề nào.
  final String? topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = topic != null;

    return Material(
      color: isSelected ? AppColors.primary : AppColors.primaryLight,
      borderRadius: AppRadius.chipBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chipBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                topic ?? AppLabels.chooseTopic,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? AppColors.textOnPrimary
                      : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.expand_more_rounded,
                size: 16,
                color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
