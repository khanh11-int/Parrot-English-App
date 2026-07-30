import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/community_providers.dart';
import 'post_card.dart';

/// Tab 1 — Dòng thời gian.
class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final controller = ref.read(feedProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(feedProvider.future),
      child: AsyncValueView(
        value: feedAsync,
        onRetry: () => ref.invalidate(feedProvider),
        data: (posts) => posts.isEmpty
            ? const EmptyState(
                message:
                    'Chưa có bài đăng nào.\nHãy là người đầu tiên chia sẻ!',
                mascotAsset: AppAssets.mascotCamera,
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: posts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.cardGap),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(
                    post: post,
                    onLike: () => controller.toggleLike(post.id),
                    onBookmark: () => controller.toggleBookmark(post.id),
                    onComment: () =>
                        context.push(AppRoutes.postCommentsOf(post.id)),
                    onSaveWord: () =>
                        _showSaved(context, post.sharedWord.english),
                    onSpeak: () => _showComingSoon(context, 'Phát âm'),
                    onTopicTap: () => _showComingSoon(context, 'Chọn chủ đề'),
                  );
                },
              ),
      ),
    );
  }

  void _showSaved(BuildContext context, String word) =>
      _showMessage(context, 'Đã lưu "$word" vào bộ từ của bạn.');

  void _showComingSoon(BuildContext context, String feature) =>
      _showMessage(context, '$feature sẽ có ở bản sau.');

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: AppDurations.snackBar),
      );
  }
}
