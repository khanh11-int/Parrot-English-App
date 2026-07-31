import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/learn_question.dart';

/// Tổng kết sau khi hoàn thành phiên học / ôn tập.
class SessionSummaryPage extends StatelessWidget {
  const SessionSummaryPage({super.key, required this.result});

  final SessionResult result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Spacer(),
          Image.asset(
            // Làm tốt thì mascot ăn mừng, làm chưa tốt thì mascot động viên.
            result.accuracy >= _goodAccuracy
                ? AppAssets.mascotTrophy
                : AppAssets.stickerCheer,
            width: 160,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            result.accuracy >= _goodAccuracy ? 'Tuyệt vời!' : 'Cố lên!',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Bạn đã hoàn thành ${result.learnedWordCount} vòng, '
            'đúng ${result.correctCount}/${result.totalAnswers} lần.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _RewardTile(
                  asset: AppAssets.itemCoin,
                  label: AppLabels.seed,
                  amount: result.earnedSeeds,
                  color: AppColors.coinSeed,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _RewardTile(
                  // Lá, không phải kim cương: kim cương là ngọc (tiền cứng),
                  // dùng cho XP sẽ khiến người học tưởng vừa nhận được ngọc.
                  icon: Icons.eco_rounded,
                  label: AppLabels.experience,
                  amount: result.earnedExperience,
                  color: AppColors.leafDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            label: AppLabels.finish,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  /// Từ mức này trở lên coi là làm tốt.
  static const _goodAccuracy = 0.7;
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.label,
    required this.amount,
    required this.color,
    this.asset,
    this.icon,
  });

  /// Ảnh vật phẩm; dùng cho hạt và ngọc vì đã có sẵn asset.
  final String? asset;

  /// Icon hệ thống; dùng cho XP vì chưa có ảnh lá riêng.
  final IconData? icon;
  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.leafLight,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Column(
        children: [
          if (asset case final assetPath?)
            Image.asset(assetPath, width: 32, height: 32)
          else
            Icon(icon, size: 32, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '+$amount',
            style: AppTextStyles.titleMedium.copyWith(color: color),
          ),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
