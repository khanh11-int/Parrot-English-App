import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

/// Trạng thái danh sách rỗng: mascot + một câu dẫn + nút hành động tuỳ chọn.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.mascotAsset = AppAssets.stickerThinking,
    this.actionLabel,
    this.onAction,
    this.secondaryAction,
  });

  final String message;
  final String mascotAsset;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Hành động thứ hai (ví dụ "Tham gia nhóm" bên cạnh "Tạo nhóm").
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(mascotAsset, width: 140),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            if (label != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: label,
                onPressed: onAction,
                isExpanded: false,
              ),
            ],
            if (secondaryAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              secondaryAction!,
            ],
          ],
        ),
      ),
    );
  }
}
