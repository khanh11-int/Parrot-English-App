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
import '../../../../shared/widgets/jungle_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/review_deck.dart';
import '../providers/review_providers.dart';

/// Tab Ôn tập — mục 5.5 `docs/UI_SPEC.md`.
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
    // Chỉ liệt kê bộ từ đã học. Chủ đề chưa chạm tới thì không ôn được, để ở đây
    // chỉ đẩy phần dùng được xuống dưới màn hình — chúng gom thành một dòng dẫn
    // sang tab Học từ mới ở cuối trang.
    final reviewable = decks.where((deck) => deck.canReview).toList()
      // Có từ đến hạn lên trước (việc cần làm hôm nay), rồi tới bộ học nhiều
      // hơn — bộ đang học dở đáng ôn hơn bộ mới chạm một hai từ.
      ..sort((a, b) {
        final byDue = b.dueCount.compareTo(a.dueCount);
        return byDue != 0 ? byDue : b.learnedCount.compareTo(a.learnedCount);
      });
    final untouched = decks.length - reviewable.length;

    final dueCount = decks.fold<int>(0, (sum, deck) => sum + deck.dueCount);
    final learnedCount = reviewable.fold<int>(
      0,
      (sum, deck) => sum + deck.learnedCount,
    );
    final nextDueAt = _earliestNextDue(decks);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        const SizedBox(height: AppSpacing.sm),
        _DueSummaryCard(
          dueCount: dueCount,
          learnedCount: learnedCount,
          nextDueAt: nextDueAt,
          // Chỉ chặn khi thật sự chưa học từ nào. Học rồi mà chưa tới hạn thì
          // vẫn cho ôn lại — xem `FirebaseLearnRepository.getReviewSession`.
          onStart: learnedCount > 0
              ? () => context.push(AppRoutes.reviewSession)
              : null,
        ),
        if (reviewable.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Bộ từ của bạn'),
          for (final deck in reviewable) ...[
            _DeckCard(
              deck: deck,
              onTap: () =>
                  context.push(AppRoutes.reviewSessionOfTopic(deck.topicId)),
            ),
            const SizedBox(height: AppSpacing.cardGap),
          ],
        ],
        if (untouched > 0) ...[
          const SizedBox(height: AppSpacing.md),
          _UntouchedTopicsTile(count: untouched),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Mốc đến hạn gần nhất trong mọi bộ từ; `null` nếu không có bộ nào đang chờ.
  static DateTime? _earliestNextDue(List<ReviewDeck> decks) {
    DateTime? earliest;
    for (final deck in decks) {
      if (deck.nextDueAt case final dueAt?) {
        if (earliest == null || dueAt.isBefore(earliest)) earliest = dueAt;
      }
    }
    return earliest;
  }
}

/// Thẻ đầu trang: việc cần làm bây giờ + nút bắt đầu.
class _DueSummaryCard extends StatelessWidget {
  const _DueSummaryCard({
    required this.dueCount,
    required this.learnedCount,
    required this.nextDueAt,
    required this.onStart,
  });

  final int dueCount;

  /// Tổng số từ đã học. Còn từ đã học là còn ôn lại được, dù chưa tới hạn.
  final int learnedCount;

  /// Mốc đến hạn gần nhất, để nói được "hôm nào có cái ôn".
  final DateTime? nextDueAt;

  /// `null` khi chưa học từ nào → nút bị vô hiệu hoá.
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    // Ba trạng thái, mỗi trạng thái phải nói rõ việc tiếp theo là gì. Trước đây
    // hết từ đến hạn là hiện "Quay lại vào ngày mai nhé" kèm nút xám, người học
    // vừa học xong hai chủ đề vẫn không ôn được gì.
    final (title, subtitle, buttonLabel) = switch ((dueCount, learnedCount)) {
      (0, 0) => (
        'Chưa có gì để ôn',
        'Học từ mới trước rồi quay lại đây',
        'Ôn tập ngay',
      ),
      (0, _) => (
        'Không còn từ nào đến hạn',
        _waitingSubtitle(learnedCount, nextDueAt),
        'Ôn lại từ đã học',
      ),
      _ => (
        '$dueCount từ đến hạn ôn',
        'Ôn ngay để giữ chuỗi streak',
        'Ôn tập ngay',
      ),
    };

    return JungleCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: buttonLabel,
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

  static String _waitingSubtitle(int learnedCount, DateTime? nextDueAt) {
    final when = describeDueIn(nextDueAt);
    if (when == null) return 'Ôn lại $learnedCount từ đã học cho nhớ lâu';
    return 'Đến hạn tiếp $when · ôn lại luôn cũng được';
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.deck, required this.onTap});

  final ReviewDeck deck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgBase,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        // Bấm để ôn riêng bộ từ này. Trước đây thẻ chỉ để xem, muốn ôn một chủ
        // đề cụ thể thì không có cách nào.
        onTap: onTap,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: AppSpacing.cardPadding,
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
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Thanh đo theo số từ **đã học** để khớp với trang Học từ mới. Nếu
              // đo theo "đã thuộc" thì chủ đề vừa học xong vẫn hiện thanh rỗng,
              // vì thuộc một từ cần ôn đúng vài lần trải qua ba tuần.
              AppLinearProgress(
                value: deck.learnedProgress,
                color: AppColors.leaf,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(_subtitleFor(deck), style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }

  /// Dòng phụ nói **một** thông tin hữu ích, không liệt kê mọi con số.
  ///
  /// Bỏ "thuộc 0" đi: số đó cần khoảng lặp lại 21 ngày mới khác 0 nên suốt mấy
  /// tuần đầu nó chỉ là con số 0 lặp lại ở mọi thẻ.
  static String _subtitleFor(ReviewDeck deck) {
    final progress = 'Đã học ${deck.learnedCount}/${deck.totalCount} từ';
    if (deck.masteredCount > 0) {
      return '$progress · thuộc ${deck.masteredCount}';
    }
    final when = describeDueIn(deck.nextDueAt);
    return when == null ? progress : '$progress · đến hạn $when';
  }
}

/// Một dòng gom các chủ đề chưa học, dẫn sang tab Học từ mới.
class _UntouchedTopicsTile extends StatelessWidget {
  const _UntouchedTopicsTile({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    // Nền trong suốt: đây là ghi chú dẫn đường, không phải một bộ từ.
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: () => context.push(AppRoutes.learnTopics),
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: [
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Còn $count chủ đề chưa học',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
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

/// Mô tả mốc đến hạn theo lời người nói: `hôm nay` / `mai` / `3 ngày nữa`.
///
/// Trả `null` khi không có mốc nào — chỗ gọi tự quyết định hiện gì thay thế.
/// Đếm theo **ngày lịch** chứ không theo số giờ chênh lệch: 20h hôm nay tới 8h
/// mai chỉ cách 12 tiếng, nhưng người học vẫn gọi đó là "mai".
String? describeDueIn(DateTime? dueAt, {DateTime? now}) {
  if (dueAt == null) return null;

  final today = _dateOnly(now ?? DateTime.now());
  final days = _dateOnly(dueAt).difference(today).inDays;

  return switch (days) {
    <= 0 => 'hôm nay',
    1 => 'mai',
    _ => '$days ngày nữa',
  };
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
