import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
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

/// Thẻ tài khoản: hiện email đang đăng nhập + nút đăng xuất.
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
          ListTile(
            leading: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textSecondary,
            ),
            title: Text('Đang đăng nhập', style: AppTextStyles.caption),
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
