import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_circular_progress.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../domain/entities/vocabulary_topic.dart';

/// Một dòng chủ đề: vòng tiến độ bên trái, tên và số từ ở giữa.
class TopicProgressTile extends StatelessWidget {
  const TopicProgressTile({
    super.key,
    required this.topic,
    required this.onTap,
  });

  final VocabularyTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Chủ đề học xong chuyển sang xanh lá để phân biệt ngay với chủ đề đang học.
    final ringColor = topic.isCompleted ? AppColors.leaf : AppColors.primary;

    return Material(
      color: AppColors.bgBase,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              AppCircularProgress(
                value: topic.progress,
                size: 56,
                color: ringColor,
                trackColor: topic.isCompleted
                    ? AppColors.leafLight
                    : AppColors.neutral,
                child: AppImage(source: topic.iconAsset),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      topic.name,
                      style: AppTextStyles.bodyBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${topic.learnedCount}/${topic.totalCount} từ',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _TopicStatusChip(topic: topic),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${topic.percent}%',
                style: AppTextStyles.bodyBold.copyWith(color: ringColor),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nhãn trạng thái: còn bao nhiêu từ mới, hoặc đã học xong.
class _TopicStatusChip extends StatelessWidget {
  const _TopicStatusChip({required this.topic});

  final VocabularyTopic topic;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = topic.isCompleted
        ? (AppColors.leafLight, AppColors.leafDark, 'Đã học xong')
        : (
            AppColors.primaryLight,
            AppColors.primary,
            'Còn ${topic.remainingCount} từ mới',
          );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.chipBorder,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
