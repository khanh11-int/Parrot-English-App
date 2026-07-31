import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/badge_avatar.dart';
import '../../../../shared/widgets/rank_avatar.dart';
import '../../domain/entities/community_entities.dart';
import '../providers/community_providers.dart';

/// Tab 3 — Bảng xếp hạng giải đấu tuần.
class LeaderboardTab extends ConsumerWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return AsyncValueView(
      value: leaderboardAsync,
      onRetry: () => ref.invalidate(leaderboardProvider),
      data: (leaderboard) => _LeaderboardContent(leaderboard: leaderboard),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  const _LeaderboardContent({required this.leaderboard});

  final Leaderboard leaderboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _LeagueCard(currentRank: leaderboard.currentRank),
              const SizedBox(height: AppSpacing.lg),
              for (final entry in leaderboard.entries) ...[
                if (entry.rank == leaderboard.safeZoneEndRank + 1)
                  const _ZoneDivider(label: 'TOP AN TOÀN'),
                _LeaderboardRow(entry: entry),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        // Hàng của mình luôn hiện ở đáy, kể cả khi đã cuộn qua — người dùng
        // không phải đi tìm vị trí của chính mình.
        _StickyCurrentUserRow(leaderboard: leaderboard),
      ],
    );
  }
}

/// Ba hạng giải đấu, hạng hiện tại có viền xanh.
class _LeagueCard extends StatelessWidget {
  const _LeagueCard({required this.currentRank});

  final ForestRank currentRank;

  @override
  Widget build(BuildContext context) {
    // Hiện hạng trước, hạng hiện tại và hạng kế tiếp — đủ để người dùng thấy
    // mình đang ở đâu và sắp lên đâu.
    final ranks = <ForestRank?>[
      currentRank.index > 0 ? ForestRank.values[currentRank.index - 1] : null,
      currentRank,
      currentRank.next,
    ];

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Giải đấu tuần', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final rank in ranks)
                if (rank == null)
                  const SizedBox(width: 64)
                else
                  BadgeAvatar(
                    asset: rank.index <= currentRank.index
                        ? AppAssets.itemShield
                        : AppAssets.itemLock,
                    label: rank.label,
                    isUnlocked: rank.index <= currentRank.index,
                    isHighlighted: rank == currentRank,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dải phân cách vùng giữ hạng / xuống hạng.
class _ZoneDivider extends StatelessWidget {
  const _ZoneDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.leaf)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.leafDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.leaf)),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.primaryLight : AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: _RankMark(rank: entry.rank)),
          const SizedBox(width: AppSpacing.sm),
          RankAvatar.fromExperience(
            experience: entry.experience,
            size: 36,
            avatarAsset: entry.avatarAsset,
            backgroundColor: AppColors.leafLight,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: entry.isCurrentUser
                  ? AppTextStyles.bodyBold
                  : AppTextStyles.body,
            ),
          ),
          Text(
            '${entry.experience}',
            style: AppTextStyles.bodyBold.copyWith(color: AppColors.leafDark),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.eco_rounded, size: 16, color: AppColors.leaf),
        ],
      ),
    );
  }
}

/// Số hạng, thay bằng huy chương cho top 3.
class _RankMark extends StatelessWidget {
  const _RankMark({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    const medalColors = {
      1: AppColors.sun,
      2: AppColors.textDisabled,
      3: AppColors.coinSeed,
    };
    final medalColor = medalColors[rank];

    if (medalColor != null) {
      return Icon(Icons.military_tech_rounded, size: 24, color: medalColor);
    }
    return Text(
      '$rank',
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyBold.copyWith(color: AppColors.textSecondary),
    );
  }
}

class _StickyCurrentUserRow extends StatelessWidget {
  const _StickyCurrentUserRow({required this.leaderboard});

  final Leaderboard leaderboard;

  @override
  Widget build(BuildContext context) {
    final currentUser = leaderboard.entries
        .where((entry) => entry.isCurrentUser)
        .firstOrNull;
    if (currentUser == null) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: _LeaderboardRow(entry: currentUser),
    );
  }
}
