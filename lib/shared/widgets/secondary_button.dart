import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Nút hành động phụ: nền trắng, viền xanh. Dùng cạnh [PrimaryButton] khi có
/// hai hành động ngang hàng nhau (ví dụ "Lưu và đăng tải").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;

  static const _height = 48.0;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    final button = SizedBox(
      height: _height,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.bgBase,
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          side: BorderSide(
            color: isEnabled ? AppColors.primary : AppColors.divider,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonBorder,
          ),
          textStyle: AppTextStyles.button,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
