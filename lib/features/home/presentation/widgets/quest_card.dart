import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_linear_progress.dart';
import '../../domain/entities/home_summary.dart';

/// Thẻ nhóm nhiệm vụ hằng ngày: mỗi nhiệm vụ một dòng, thanh tiến độ chiếm hết
/// chiều ngang.
///
/// Thanh tiến độ đặt riêng một dòng dưới nhãn (thay vì nhồi cùng hàng với nhãn)
/// vì tên nhiệm vụ tiếng Việt khá dài, xếp cùng hàng sẽ bị bóp còn vài chục pixel.
class QuestCard extends StatelessWidget {
  const QuestCard({super.key, required this.group, this.onTap});

  final QuestGroup group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgBase,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            children: [
              for (final quest in group.quests) ...[
                _QuestRow(quest: quest),
                if (quest != group.quests.last)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(height: 1),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context) {
    final isDone = quest.isCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Nhiệm vụ xong được đánh dấu bằng cả icon và gạch ngang, không chỉ
            // bằng màu — người khó phân biệt màu vẫn nhận ra.
            Icon(
              isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: isDone ? AppColors.leaf : AppColors.textDisabled,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                quest.title,
                maxLines: 2,
                style: AppTextStyles.body.copyWith(
                  color: isDone
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${quest.completed}/${quest.target}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: isDone ? AppColors.leaf : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppLinearProgress(
          value: quest.progress,
          color: isDone ? AppColors.leaf : AppColors.primary,
          height: 6,
        ),
      ],
    );
  }
}

/// Dải nhiệm vụ tháng: một dòng gọn, đặt ngay dưới tiêu đề mục "Nhiệm vụ".
class MonthlyQuestBar extends StatelessWidget {
  const MonthlyQuestBar({super.key, required this.group, this.onTap});

  final QuestGroup group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.leafLight,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: AppColors.leafDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  group.title,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.leafDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${group.percent}%',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.leafDark,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.leafDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
