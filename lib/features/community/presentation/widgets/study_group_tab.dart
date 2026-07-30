import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/badge_avatar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/entities/community_entities.dart';
import '../providers/community_providers.dart';

/// Tab 2 — Nhóm học tập.
class StudyGroupTab extends ConsumerWidget {
  const StudyGroupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(studyGroupProvider);

    return AsyncValueView(
      value: groupAsync,
      onRetry: () => ref.invalidate(studyGroupProvider),
      data: (group) => group == null
          ? EmptyState(
              message:
                  'Bạn chưa tham gia nhóm nào.\n'
                  'Học cùng nhóm để cùng trồng cây từ vựng!',
              mascotAsset: AppAssets.stickerHello,
              actionLabel: 'Tạo nhóm',
              onAction: () {},
              secondaryAction: SecondaryButton(
                label: 'Tham gia nhóm',
                onPressed: () {},
                isExpanded: false,
              ),
            )
          : _GroupContent(group: group),
    );
  }
}

class _GroupContent extends StatelessWidget {
  const _GroupContent({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _GroupHeaderCard(group: group),
        const SizedBox(height: AppSpacing.cardGap),
        _MilestoneCard(group: group),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _GroupHeaderCard extends StatelessWidget {
  const _GroupHeaderCard({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        gradient: AppColors.canopyGradient,
        borderRadius: AppRadius.cardLargeBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: AppImage(source: group.avatarAsset, width: 40),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                Text(
                  '${group.memberCount} thành viên',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                Text(
                  'Trưởng nhóm: ${group.leaderName}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ],
            ),
          ),
          const _GroupActions(),
        ],
      ),
    );
  }
}

class _GroupActions extends StatelessWidget {
  const _GroupActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _GroupActionIcon(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Thông báo',
        ),
        _GroupActionIcon(
          icon: Icons.chat_bubble_outline_rounded,
          tooltip: 'Chat nhóm',
        ),
        _GroupActionIcon(icon: Icons.logout_rounded, tooltip: 'Rời nhóm'),
      ],
    );
  }
}

class _GroupActionIcon extends StatelessWidget {
  const _GroupActionIcon({required this.icon, required this.tooltip});

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: null,
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      color: AppColors.textOnPrimary,
      disabledColor: Colors.white70,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
    );
  }
}

/// Thẻ 3 mốc Chồi Non → Cây Vững → Đại Thụ + XP tích luỹ của nhóm.
class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context) {
    final current = group.currentMilestone;

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
                child: Text('Mốc hiện tại', style: AppTextStyles.caption),
              ),
              _DaysRemainingChip(days: group.daysRemaining),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            current?.label ?? 'Đã đạt hết các mốc',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final milestone in GroupMilestone.values)
                _MilestoneBadge(
                  milestone: milestone,
                  isUnlocked: group.isMilestoneUnlocked(milestone),
                  isCurrent: milestone == current,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  '${group.totalExperience}',
                  style: AppTextStyles.displayNumber.copyWith(
                    color: AppColors.leafDark,
                  ),
                ),
                Text('XP tích luỹ của nhóm', style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneBadge extends StatelessWidget {
  const _MilestoneBadge({
    required this.milestone,
    required this.isUnlocked,
    required this.isCurrent,
  });

  final GroupMilestone milestone;
  final bool isUnlocked;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BadgeAvatar(
          // Chưa có bộ huy hiệu cây riêng nên tạm dùng icon vật phẩm; đổi asset
          // sau không ảnh hưởng bố cục.
          asset: isUnlocked ? AppAssets.itemTarget : AppAssets.itemLock,
          isUnlocked: isUnlocked,
          isHighlighted: isCurrent,
          size: 56,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${milestone.requiredExperience}',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.eco_rounded, size: 12, color: AppColors.leaf),
          ],
        ),
        SizedBox(
          width: 76,
          child: Text(
            milestone.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: isUnlocked
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
          ),
        ),
      ],
    );
  }
}

class _DaysRemainingChip extends StatelessWidget {
  const _DaysRemainingChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.leafLight,
        borderRadius: AppRadius.chipBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: AppColors.leafDark),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$days ngày còn lại',
            style: AppTextStyles.caption.copyWith(color: AppColors.leafDark),
          ),
        ],
      ),
    );
  }
}
