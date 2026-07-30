import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/saved_word.dart';
import '../providers/vocabulary_providers.dart';

/// Danh sách từ người dùng đã lưu từ ảnh chụp.
///
/// Tách hẳn khỏi phần "Học từ mới": đây là sổ tay để xem lại những vật mình đã
/// chụp, không tham gia vào giáo trình và không ảnh hưởng tiến độ chủ đề.
class SavedWordsPage extends ConsumerWidget {
  const SavedWordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(savedWordsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Từ đã lưu')),
      body: SafeArea(
        child: AsyncValueView(
          value: wordsAsync,
          onRetry: () => ref.invalidate(savedWordsControllerProvider),
          data: (words) => words.isEmpty
              ? EmptyState(
                  message:
                      'Bạn chưa lưu từ nào.\n'
                      'Chụp ảnh một vật rồi bấm "Lưu từ vựng" nhé!',
                  mascotAsset: AppAssets.mascotCamera,
                  actionLabel: 'Chụp ảnh',
                  onAction: () => context.push(AppRoutes.scan),
                )
              : _SavedWordList(words: words),
        ),
      ),
    );
  }
}

class _SavedWordList extends ConsumerWidget {
  const _SavedWordList({required this.words});

  final List<SavedWord> words;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${words.length} từ bạn đã lưu từ ảnh chụp',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final word in words) ...[
          _SavedWordTile(
            word: word,
            onRemove: () => _remove(context, ref, word),
          ),
          const SizedBox(height: AppSpacing.cardGap),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    SavedWord word,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref
        .read(savedWordsControllerProvider.notifier)
        .remove(word.id);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? 'Đã xoá "${word.english}".'),
          backgroundColor: error == null ? null : AppColors.danger,
          duration: AppDurations.snackBar,
        ),
      );
  }
}

class _SavedWordTile extends StatelessWidget {
  const _SavedWordTile({required this.word, required this.onRemove});

  final SavedWord word;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final phoneticAndMeaning = [
      if (word.phonetic.isNotEmpty) word.phonetic,
      word.vietnamese,
    ].join(' – ');

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(word.english, style: AppTextStyles.wordEnglish),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  phoneticAndMeaning,
                  style: AppTextStyles.wordMeaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.textSecondary,
            tooltip: 'Xoá khỏi danh sách',
          ),
        ],
      ),
    );
  }
}
