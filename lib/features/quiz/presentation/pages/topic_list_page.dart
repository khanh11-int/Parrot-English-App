import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_circular_progress.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/entities/vocabulary_topic.dart';
import '../providers/learn_providers.dart';
import '../widgets/topic_progress_tile.dart';

/// Chọn chủ đề để học từ mới.
///
/// Bước đệm giữa trang chủ và phiên học: người học thấy được mình đang dở chủ đề
/// nào rồi mới quyết định học tiếp cái gì, thay vì bị đẩy thẳng vào một phiên
/// trộn lẫn mọi chủ đề.
class TopicListPage extends ConsumerWidget {
  const TopicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(learnTopicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Học từ mới')),
      body: SafeArea(
        child: AsyncValueView(
          value: topicsAsync,
          onRetry: () => ref.invalidate(learnTopicsProvider),
          data: (topics) => topics.isEmpty
              ? EmptyState(
                  message:
                      'Bạn chưa có chủ đề nào.\n'
                      'Chụp ảnh để tạo bộ từ đầu tiên nhé!',
                  mascotAsset: AppAssets.mascotCamera,
                  actionLabel: 'Gửi ảnh',
                  onAction: () => context.push(AppRoutes.scan),
                )
              : _TopicList(topics: topics),
        ),
      ),
    );
  }
}

class _TopicList extends StatelessWidget {
  const _TopicList({required this.topics});

  final List<VocabularyTopic> topics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.sm),
        _OverallCard(topics: topics),
        const SizedBox(height: AppSpacing.xl),
        Text('Chọn chủ đề', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        for (final topic in topics) ...[
          TopicProgressTile(
            topic: topic,
            onTap: () => context.push(AppRoutes.learnSessionOfTopic(topic.id)),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// Thẻ tổng: tiến độ toàn bộ chủ đề + lối học trộn mọi chủ đề.
class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.topics});

  final List<VocabularyTopic> topics;

  @override
  Widget build(BuildContext context) {
    final learned = topics.fold<int>(0, (sum, t) => sum + t.learnedCount);
    final total = topics.fold<int>(0, (sum, t) => sum + t.totalCount);
    final progress = total == 0 ? 0.0 : learned / total;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        gradient: AppColors.canopyGradient,
        borderRadius: AppRadius.cardLargeBorder,
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppCircularProgress(
                value: progress,
                size: 64,
                strokeWidth: 6,
                color: AppColors.sun,
                trackColor: const Color(0x33FFFFFF),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã học $learned/$total từ',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${topics.length} chủ đề',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            label: 'Học trộn mọi chủ đề',
            onPressed: () => context.push(AppRoutes.learnSession),
          ),
        ],
      ),
    );
  }
}
