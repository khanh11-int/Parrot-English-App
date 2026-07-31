import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/badge_avatar.dart';
import '../../../../shared/widgets/jungle_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/community_entities.dart';
import '../providers/community_providers.dart';
import 'group_join_sheet.dart';
import 'joinable_group_card.dart';

/// Tab 2 — Nhóm học tập.
class StudyGroupTab extends ConsumerWidget {
  const StudyGroupTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(studyGroupProvider);

    return AsyncValueView(
      value: groupAsync,
      onRetry: () => ref.invalidate(studyGroupProvider),
      data: (group) =>
          group == null ? const _NoGroupContent() : _GroupContent(group: group),
    );
  }
}

/// Chưa vào nhóm nào: lời mời + nút tạo nhóm + **danh sách nhóm có thể tham gia
/// ngay trên trang**.
///
/// Trước đây chỗ này là `EmptyState` với hai nút, danh sách nhóm nằm trong một
/// bottom sheet phải bấm mới thấy. Người vừa rời nhóm mở tab lên thấy một trang
/// trống, không biết có nhóm nào để vào hay không.
class _NoGroupContent extends ConsumerWidget {
  const _NoGroupContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(joinableGroupsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(joinableGroupsProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _InviteCard(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Nhóm có thể tham gia'),
          AsyncValueView(
            value: groupsAsync,
            onRetry: () => ref.invalidate(joinableGroupsProvider),
            // Skeleton mặc định là một `ListView`; đặt trong `ListView` ngoài
            // này thì thành hai vùng cuộn lồng nhau và ném "unbounded height".
            // Bản này chỉ là mấy khối xếp dọc, không cuộn.
            loading: const _JoinableSkeleton(),
            data: (groups) => groups.isEmpty
                ? const _NoJoinableGroupsNote()
                : Column(
                    children: [
                      for (final group in groups) ...[
                        JoinableGroupCard(group: group),
                        const SizedBox(height: AppSpacing.cardGap),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

/// Thẻ mời tạo nhóm, đặt trên đầu trang khi chưa vào nhóm nào.
class _InviteCard extends ConsumerWidget {
  const _InviteCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JungleCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn chưa ở nhóm nào',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Học cùng nhóm để cùng trồng cây từ vựng',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Tạo nhóm mới',
                  isExpanded: false,
                  onPressed: () => showCreateGroupSheet(context, ref),
                ),
              ],
            ),
          ),
          Image.asset(AppAssets.stickerHello, width: 80),
        ],
      ),
    );
  }
}

/// Skeleton của danh sách nhóm — **không cuộn**, để lồng được trong `ListView`.
class _JoinableSkeleton extends StatelessWidget {
  const _JoinableSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBox(height: 72, borderRadius: AppRadius.cardBorder),
        SizedBox(height: AppSpacing.cardGap),
        SkeletonBox(height: 72, borderRadius: AppRadius.cardBorder),
      ],
    );
  }
}

class _NoJoinableGroupsNote extends StatelessWidget {
  const _NoJoinableGroupsNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Text(
        'Chưa có nhóm nào để tham gia. Tạo nhóm đầu tiên đi!',
        style: AppTextStyles.body,
      ),
    );
  }
}

class _GroupContent extends ConsumerWidget {
  const _GroupContent({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class _GroupHeaderCard extends ConsumerWidget {
  const _GroupHeaderCard({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return JungleCard(
      decor: AppAssets.decorPalmCluster,
      decorWidth: 120,
      decorHeight: 143,
      decorOffset: const Offset(-16, -22),
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
          _GroupActions(group: group),
        ],
      ),
    );
  }
}

class _GroupActions extends ConsumerWidget {
  const _GroupActions({required this.group});

  final StudyGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Thông báo nhóm chưa làm nên để `null`: người dùng thấy ngay là chưa
        // bấm được thay vì bấm rồi không có gì xảy ra.
        const _GroupActionIcon(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Thông báo (chưa có)',
        ),
        _GroupActionIcon(
          icon: Icons.chat_bubble_outline_rounded,
          tooltip: 'Chat nhóm',
          onPressed: () => context.push(AppRoutes.groupChatOf(group.id)),
        ),
        _GroupActionIcon(
          icon: Icons.logout_rounded,
          tooltip: 'Rời nhóm',
          onPressed: () => _confirmLeave(context, ref),
        ),
      ],
    );
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Rời nhóm ${group.name}?'),
        content: const Text(
          'XP bạn đã kiếm vẫn giữ nguyên, chỉ không còn tính vào nhóm này nữa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Rời nhóm',
              style: AppTextStyles.button.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (shouldLeave != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(groupActionsProvider).leave();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? 'Đã rời nhóm ${group.name}.'),
          backgroundColor: error == null ? null : AppColors.danger,
          duration: AppDurations.snackBar,
        ),
      );
  }
}

class _GroupActionIcon extends StatelessWidget {
  const _GroupActionIcon({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
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
          // Cây lớn dần theo mốc: bụi lá → dừa non → dừa lớn. Mốc chưa đạt vẫn
          // hiện đúng cây của nó, chỉ bị làm xám — người xem thấy trước mình
          // đang trồng cái gì, thay vì một ô khoá vô nghĩa.
          asset: AppAssets.milestoneBadge(milestone.index),
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
