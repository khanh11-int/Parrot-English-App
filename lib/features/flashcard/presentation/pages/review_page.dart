import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_linear_progress.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/review_deck.dart';
import '../providers/review_providers.dart';

/// Tab Ôn tập — danh sách bộ từ đến hạn ôn theo SRS (mục 5.5 `UI_SPEC.md`).
class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(reviewDecksProvider);

    return SafeArea(
      child: AsyncValueView(
        value: decksAsync,
        onRetry: () => ref.invalidate(reviewDecksProvider),
        data: (decks) => _ReviewContent(decks: decks),
      ),
    );
  }
}

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({required this.decks});

  final List<ReviewDeck> decks;

  @override
  Widget build(BuildContext context) {
    final dueCount = decks.fold<int>(0, (sum, deck) => sum + deck.dueCount);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.sm),
        _DueSummaryCard(
          dueCount: dueCount,
          onStart: dueCount > 0
              ? () => context.push(AppRoutes.reviewSession)
              : null,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Bộ từ của bạn'),
        for (final deck in decks) ...[
          _DeckCard(deck: deck),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Thẻ tổng số từ đến hạn ôn + nút bắt đầu phiên.
class _DueSummaryCard extends StatelessWidget {
  const _DueSummaryCard({required this.dueCount, required this.onStart});

  final int dueCount;

  /// `null` khi không còn từ nào đến hạn → nút bị vô hiệu hoá.
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        gradient: AppColors.canopyGradient,
        borderRadius: AppRadius.cardLargeBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dueCount > 0
                      ? '$dueCount từ đến hạn ôn'
                      : 'Không còn từ nào đến hạn',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dueCount > 0
                      ? 'Ôn ngay để giữ chuỗi streak'
                      : 'Quay lại vào ngày mai nhé',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Ôn tập ngay',
                  onPressed: onStart,
                  isExpanded: false,
                ),
              ],
            ),
          ),
          Image.asset(AppAssets.mascotPhone, width: 80),
        ],
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck});

  final ReviewDeck deck;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deck.topic,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (deck.dueCount > 0) _DueBadge(count: deck.dueCount),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppLinearProgress(value: deck.masteryProgress, color: AppColors.leaf),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Đã thuộc ${deck.masteredCount}/${deck.totalCount} từ',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.chipBorder,
      ),
      child: Text(
        '$count đến hạn',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
