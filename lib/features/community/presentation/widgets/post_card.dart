import 'package:flutter/material.dart';

import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/vocab_card.dart';
import '../../domain/entities/community_entities.dart';

/// Một bài đăng trên dòng thời gian: tác giả → ảnh có khung nhận diện → thẻ từ
/// vựng lưu được → hàng tương tác.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onBookmark,
    required this.onComment,
    required this.onSaveWord,
    required this.onSpeak,
    required this.onTopicTap,
  });

  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onComment;
  final VoidCallback onSaveWord;
  final VoidCallback onSpeak;
  final VoidCallback onTopicTap;

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
          _PostHeader(post: post),
          const SizedBox(height: AppSpacing.md),
          _PostImage(detectedLabel: post.detectedLabel),
          const SizedBox(height: AppSpacing.md),
          VocabCard(
            english: post.sharedWord.english,
            vietnamese: post.sharedWord.vietnamese,
            phonetic: post.sharedWord.phonetic,
            onSpeak: onSpeak,
            onTopicTap: onTopicTap,
            // Nút lưu nằm trong thẻ từ: đây là giá trị chính của feed — học
            // được từ mà người khác đã chụp.
            trailingAction: PrimaryButton(
              label: AppLabels.saveVocabulary,
              onPressed: onSaveWord,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _InteractionRow(
            post: post,
            onLike: onLike,
            onBookmark: onBookmark,
            onComment: onComment,
          ),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.leafLight,
          child: AppImage(source: post.authorAvatarAsset, width: 32),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: AppTextStyles.bodyBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(post.timeAgo, style: AppTextStyles.caption),
            ],
          ),
        ),
        IconButton(
          onPressed: null,
          icon: const Icon(Icons.more_vert_rounded),
          tooltip: 'Tuỳ chọn bài đăng',
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}

/// Ảnh của bài đăng kèm chip nhãn nhận diện.
///
/// Chưa có ảnh thật từ backend nên dùng khung giả với tỉ lệ cố định — bố cục
/// không nhảy khi thay bằng ảnh thật.
class _PostImage extends StatelessWidget {
  const _PostImage({required this.detectedLabel});

  final String detectedLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.imageBorder,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ColoredBox(
          color: AppColors.neutral,
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: AppColors.textDisabled,
                ),
              ),
              Positioned(
                left: AppSpacing.sm,
                top: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: AppRadius.chipBorder,
                  ),
                  child: Text(
                    detectedLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.bgBase,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InteractionRow extends StatelessWidget {
  const _InteractionRow({
    required this.post,
    required this.onLike,
    required this.onBookmark,
    required this.onComment,
  });

  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _InteractionButton(
          icon: post.isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          count: post.likeCount,
          color: post.isLiked ? AppColors.danger : AppColors.textSecondary,
          tooltip: 'Thích',
          onPressed: onLike,
        ),
        const SizedBox(width: AppSpacing.lg),
        _InteractionButton(
          icon: Icons.chat_bubble_outline_rounded,
          count: post.commentCount,
          color: AppColors.textSecondary,
          tooltip: 'Bình luận',
          onPressed: onComment,
        ),
        const SizedBox(width: AppSpacing.lg),
        _InteractionButton(
          icon: post.isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          count: post.bookmarkCount,
          color: post.isBookmarked
              ? AppColors.primary
              : AppColors.textSecondary,
          tooltip: 'Lưu bài',
          onPressed: onBookmark,
        ),
      ],
    );
  }
}

class _InteractionButton extends StatelessWidget {
  const _InteractionButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final int count;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.chipBorder,
        child: Padding(
          // Vùng chạm cao 44px theo yêu cầu khả năng tiếp cận.
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$count',
                style: AppTextStyles.caption.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
