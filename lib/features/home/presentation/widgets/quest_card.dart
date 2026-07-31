import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
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
/// Thẻ này **không bấm được**: trang chi tiết nhiệm vụ chưa có. Trước đây nó bọc
/// `InkWell` với `onTap: null` nên hiện hiệu ứng chạm rồi không đi đâu cả.
class QuestCard extends StatelessWidget {
  const QuestCard({super.key, required this.group});

  final QuestGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
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

/// Thẻ tiến độ cả giáo trình: `16/56 từ` + thanh + `%`, bấm để mở danh sách chủ
/// đề.
///
/// Thay cho dải một dòng cũ chỉ hiện được `%`: hai con số bị nhồi vào **chuỗi
/// tiêu đề** của một `Quest` ("Học hết 56 từ trong giáo trình") nên UI không tách
/// ra được. Và chevron cũ dẫn tới một trang chi tiết chưa tồn tại — giờ nó dẫn
/// sang `/learn`, một đích có thật.
class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.learnedCount,
    required this.totalCount,
    required this.percent,
    required this.progress,
    required this.onTap,
  });

  final int learnedCount;
  final int totalCount;
  final int percent;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.leafLight,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ảnh cây thật thay icon Material: cùng bộ hình với huy hiệu
                  // mốc nhóm nên hai chỗ nói cùng một ngôn ngữ hình.
                  Image.asset(
                    AppAssets.milestoneSprout,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '$learnedCount/$totalCount từ trong giáo trình',
                      style: AppTextStyles.bodyBold.copyWith(
                        color: AppColors.leafDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: AppTextStyles.bodyBold.copyWith(
                      color: AppColors.leafDark,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.leafDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppLinearProgress(
                value: progress,
                color: AppColors.leafDark,
                // Nền thanh mặc định là `neutral` xám, đặt trên `leafLight` thì
                // gần như trùng màu. Trắng mới thấy rõ phần chưa đạt.
                backgroundColor: AppColors.bgBase,
                height: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
