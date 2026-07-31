import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
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
