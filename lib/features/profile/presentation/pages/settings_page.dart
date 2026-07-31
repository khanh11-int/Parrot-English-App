import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Trang Cài đặt.
///
/// Chỉ còn thẻ tài khoản. Trước đây trên nó là danh sách 6 mục (Thông báo, Tin
/// nhắn, Thống kê học tập, Thành tích, Nhiệm vụ, Hồ sơ của tôi) — cả 6 đều
/// `onTap: null` vì chưa có trang nào, tức một danh sách chỉ để ngắm. Đã bỏ;
/// dựng lại từng mục khi trang tương ứng có thật.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            const SizedBox(height: AppSpacing.sm),
            if (currentUser != null) _AccountCard(email: currentUser.email),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Tên hiển thị + nút sửa.
///
/// Đây là chỗ **duy nhất** đặt tên sau khi đăng ký. Không có nó thì tài khoản
/// nào chưa kịp lưu tên lúc đăng ký sẽ mãi hiện phần trước `@` của email ở trang
/// chủ, Hồ sơ và Bảng xếp hạng, không cách nào sửa.
class _DisplayNameTile extends ConsumerWidget {
  const _DisplayNameTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isBusy = ref.watch(authControllerProvider);
    final name = user?.displayName?.trim() ?? '';

    return ListTile(
      leading: const Icon(Icons.badge_outlined, color: AppColors.textSecondary),
      title: Text('Tên hiển thị', style: AppTextStyles.caption),
      subtitle: Text(
        // Chưa đặt tên thì nói thẳng, đừng hiện phần trước `@` của email như
        // thể đó là tên người dùng đã chọn.
        name.isNotEmpty ? name : 'Chưa đặt — bấm để đặt tên',
        style: AppTextStyles.body.copyWith(
          color: name.isNotEmpty
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.edit_outlined, size: 20),
      onTap: isBusy ? null : () => _edit(context, ref, current: name),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    required String current,
  }) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: current),
    );
    if (newName == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final result = await ref
        .read(authControllerProvider.notifier)
        .updateDisplayName(newName);

    final message = switch (result) {
      AuthSucceeded() => 'Đã đổi tên thành "$newName".',
      AuthRejected(:final message) => message,
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: result is AuthSucceeded ? null : AppColors.danger,
          duration: AppDurations.snackBar,
        ),
      );
  }
}

/// Hộp thoại nhập tên. Trả về tên đã nhập, hoặc `null` khi huỷ.
class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tên hiển thị'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: Công Tình',
            helperText: 'Tên này hiện ở bảng xếp hạng',
          ),
          validator: AuthValidators.displayName,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        TextButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}

/// Thẻ tài khoản: tên hiển thị + email + nút đăng xuất.
class _AccountCard extends ConsumerWidget {
  const _AccountCard({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(authControllerProvider);

    // `Material` chứ không phải `Container(decoration: color)`: `ListTile` có
    // `onTap` vẽ hiệu ứng ink lên `Material` gần nhất, nền do `Container` tô sẽ
    // che mất ink và Flutter báo lỗi.
    return Material(
      color: AppColors.bgBase,
      borderRadius: AppRadius.cardBorder,
      child: Column(
        children: [
          const _DisplayNameTile(),
          const Divider(height: 1, indent: AppSpacing.lg),
          ListTile(
            leading: const Icon(
              Icons.mail_outline_rounded,
              color: AppColors.textSecondary,
            ),
            title: Text('Email', style: AppTextStyles.caption),
            subtitle: Text(email, style: AppTextStyles.body),
          ),
          const Divider(height: 1, indent: AppSpacing.lg),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
            title: Text(
              'Đăng xuất',
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
            onTap: isBusy ? null : () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn sẽ cần đăng nhập lại để tiếp tục học.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Đăng xuất',
              style: AppTextStyles.button.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;
    // Đăng xuất xong `GoRouter` tự đưa về trang đăng nhập nhờ redirect.
    await ref.read(authControllerProvider.notifier).signOut();
  }
}
