import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/community_entities.dart';
import '../providers/community_providers.dart';

/// Bottom sheet đặt tên và tạo nhóm mới.
Future<void> showCreateGroupSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CreateGroupSheet(),
  );
}

/// Bottom sheet chọn một nhóm để tham gia.
Future<void> showJoinGroupSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _JoinGroupSheet(),
  );
}

class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isBusy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isBusy = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error = await ref.read(groupActionsProvider).create(_controller.text);

    if (!mounted) return;
    setState(() => _isBusy = false);

    if (error == null) navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? 'Đã tạo nhóm "${_controller.text.trim()}".'),
          backgroundColor: error == null ? null : AppColors.danger,
          duration: AppDurations.snackBar,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Đẩy sheet lên khi bàn phím hiện, nếu không ô nhập bị che.
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tạo nhóm mới', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Bạn sẽ là trưởng nhóm. Rủ bạn bè vào cùng học nhé!',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _controller,
              label: 'Tên nhóm',
              icon: Icons.groups_rounded,
              textInputAction: TextInputAction.done,
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Vui lòng nhập tên nhóm.';
                if (text.length < 2) return 'Tên nhóm quá ngắn.';
                return null;
              },
              onSubmitted: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Tạo nhóm',
              isLoading: _isBusy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinGroupSheet extends ConsumerWidget {
  const _JoinGroupSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(joinableGroupsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: AppSpacing.pagePadding,
              child: Text('Chọn nhóm', style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            switch (groupsAsync) {
              AsyncValue(hasError: true) => const AppErrorView(
                message: 'Không tải được danh sách nhóm.',
              ),
              AsyncValue(:final valueOrNull?) =>
                valueOrNull.isEmpty
                    ? const Padding(
                        padding: AppSpacing.pagePadding,
                        child: Text(
                          'Chưa có nhóm nào. Hãy tạo nhóm đầu tiên!',
                          style: AppTextStyles.body,
                        ),
                      )
                    : Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final group in valueOrNull)
                              _GroupRow(group: group),
                          ],
                        ),
                      ),
              _ => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _GroupRow extends ConsumerWidget {
  const _GroupRow({required this.group});

  final StudyGroupSummary group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.groups_rounded, color: AppColors.leafDark),
      title: Text(group.name, style: AppTextStyles.bodyBold),
      subtitle: Text(
        '${group.memberCount} thành viên · Trưởng nhóm ${group.leaderName}',
        style: AppTextStyles.caption,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _join(context, ref),
    );
  }

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error = await ref.read(groupActionsProvider).join(group.id);

    if (error == null) navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error ?? 'Đã tham gia nhóm ${group.name}.'),
          backgroundColor: error == null ? null : AppColors.danger,
          duration: AppDurations.snackBar,
        ),
      );
  }
}
