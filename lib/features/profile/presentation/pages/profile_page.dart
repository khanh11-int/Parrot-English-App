import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/rank_avatar.dart';
import '../../../../shared/widgets/app_linear_progress.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

/// Tab Hồ sơ — mục 5.8 của `docs/UI_SPEC.md`.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(userProfileProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: profileAsync,
          onRetry: () => ref.invalidate(userProfileProvider),
          data: (profile) => _ProfileContent(profile: profile),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        _ProfileHeaderCard(profile: profile),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Tổng quan'),
        _OverviewGrid(profile: profile),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        // Chỗ này theo spec là nền hoạ tiết lá mờ; tạm dùng gradient nhạt cho
        // tới khi có asset hoạ tiết riêng.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.leafLight, AppColors.bgBase],
        ),
        borderRadius: AppRadius.cardLargeBorder,
      ),
      child: Row(
        children: [
          RankAvatar(
            rank: profile.rank,
            size: 56,
            avatarAsset: profile.avatarAsset,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              profile.name,
              style: AppTextStyles.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

/// Lưới 2×2 các số liệu chính + thanh tiến độ lên hạng kế tiếp.
class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final nextRank = profile.rank.next;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Hạng hiện tại',
                value: profile.rank.label,
                icon: Icons.forest_rounded,
                iconColor: AppColors.leafDark,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                label: 'Streak',
                value: '${profile.streakDays}',
                icon: Icons.local_fire_department_rounded,
                iconColor: AppColors.streak,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Nhóm',
                value: profile.groupName ?? 'Chưa có nhóm',
                icon: Icons.groups_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatTile(
                label: AppLabels.experience,
                value: '${profile.experience}',
                // Lá cho XP; xu vàng là hạt (tiền mềm) nên dùng ở đây sẽ lẫn.
                icon: Icons.eco_rounded,
                iconColor: AppColors.leaf,
              ),
            ),
          ],
        ),
        if (nextRank != null) ...[
          const SizedBox(height: AppSpacing.md),
          _NextRankCard(profile: profile, nextRank: nextRank),
        ],
      ],
    );
  }
}

class _NextRankCard extends StatelessWidget {
  const _NextRankCard({required this.profile, required this.nextRank});

  final UserProfile profile;
  final ForestRank nextRank;

  @override
  Widget build(BuildContext context) {
    final remaining = nextRank.requiredExperience - profile.experience;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Còn $remaining XP để lên ${nextRank.label}',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppLinearProgress(
            value: profile.progressToNextRank,
            color: AppColors.leaf,
          ),
        ],
      ),
    );
  }
}
