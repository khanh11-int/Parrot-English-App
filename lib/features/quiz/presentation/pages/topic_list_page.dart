import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
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
              // Giáo trình do admin soạn, người dùng không tự thêm chủ đề được
              // nên trạng thái rỗng chỉ báo tin, không có hành động nào.
              ? const EmptyState(
                  message:
                      'Chưa có chủ đề nào trong giáo trình.\n'
                      'Liên hệ quản trị viên để bổ sung nhé!',
                  mascotAsset: AppAssets.stickerThinking,
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
