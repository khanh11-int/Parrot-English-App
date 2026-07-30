import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Một mục trong danh sách Cài đặt.
class _SettingsEntry {
  const _SettingsEntry({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}

/// Trang Cài đặt — dùng lại bộ `assets/images/icons/`.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _entries = [
    _SettingsEntry(label: 'Thông báo', iconAsset: AppAssets.iconNotification),
    _SettingsEntry(label: 'Tin nhắn', iconAsset: AppAssets.iconMessage),
    _SettingsEntry(label: 'Thống kê học tập', iconAsset: AppAssets.iconStats),
    _SettingsEntry(label: 'Thành tích', iconAsset: AppAssets.iconAchievement),
    _SettingsEntry(label: 'Nhiệm vụ', iconAsset: AppAssets.iconQuest),
    _SettingsEntry(label: 'Hồ sơ của tôi', iconAsset: AppAssets.iconProfile),
  ];

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
            Material(
              color: AppColors.bgBase,
              borderRadius: AppRadius.cardBorder,
              child: Column(
                children: [
                  for (final entry in _entries) ...[
                    _SettingsRow(entry: entry),
                    if (entry != _entries.last)
                      const Divider(height: 1, indent: AppSpacing.lg),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.entry});

  final _SettingsEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(entry.iconAsset, width: 24, height: 24),
      title: Text(entry.label, style: AppTextStyles.body),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
      // Chưa có trang con nào; để `null` cho người dùng thấy mục chưa bấm được
      // thay vì bấm vào rồi không có gì xảy ra.
      onTap: null,
    );
  }
}
