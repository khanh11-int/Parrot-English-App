import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../domain/entities/community_entities.dart';
import '../providers/community_providers.dart';

/// Một nhóm có thể tham gia, kèm nút "Tham gia" ngay trên thẻ.
///
/// Nút hiện rõ chứ không phải cả thẻ bấm được: tham gia nhóm là việc khó lùi
/// (rời ra rồi vào lại thì mất chỗ trong bảng xếp hạng nhóm), nên phải là một
/// nút cố ý bấm, không phải chạm nhầm vào thẻ.
class JoinableGroupCard extends ConsumerStatefulWidget {
  const JoinableGroupCard({super.key, required this.group});

  final StudyGroupSummary group;

  @override
  ConsumerState<JoinableGroupCard> createState() => _JoinableGroupCardState();
}

class _JoinableGroupCardState extends ConsumerState<JoinableGroupCard> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.leafLight,
            child: Icon(Icons.groups_rounded, color: AppColors.leafDark),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: AppTextStyles.bodyBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${group.memberCount} thành viên · '
                  'Trưởng nhóm ${group.leaderName}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SecondaryButton(
            label: 'Tham gia',
            isExpanded: false,
            isLoading: _isBusy,
            onPressed: _join,
          ),
        ],
      ),
    );
  }

  Future<void> _join() async {
    setState(() => _isBusy = true);

    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(groupActionsProvider).join(widget.group.id);

    // Vào nhóm thành công thì `studyGroupProvider` đổi và cả trang này bị thay
    // bằng nội dung nhóm, nên widget không còn mounted — phải kiểm trước khi
    // `setState`.
    if (mounted) setState(() => _isBusy = false);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? 'Đã tham gia nhóm ${widget.group.name}.'),
          backgroundColor: error == null ? null : AppColors.danger,
          duration: AppDurations.snackBar,
        ),
      );
  }
}
