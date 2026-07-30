import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Ô nhập liệu theo style của app: nền xám nhạt, bo góc mềm, không viền đậm.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final VoidCallback? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      autofillHints: autofillHints,
      onFieldSubmitted: onSubmitted == null ? null : (_) => onSubmitted!(),
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.neutral,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDisabled),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        // Viền chỉ hiện khi focus hoặc lỗi, lúc bình thường dựa vào màu nền.
        border: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonBorder,
          borderSide: BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
    );
  }
}

/// Bộ kiểm tra dữ liệu nhập dùng chung cho đăng nhập và đăng ký.
abstract final class AuthValidators {
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập email.';
    // Kiểm tra tối thiểu: có `@` và có dấu chấm ở phần sau. Không dùng regex
    // phức tạp — email hợp lệ theo chuẩn rất khó biểu diễn, và server vẫn kiểm.
    final parts = text.split('@');
    if (parts.length != 2 || parts[0].isEmpty || !parts[1].contains('.')) {
      return 'Email không hợp lệ.';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Vui lòng nhập mật khẩu.';
    // Firebase từ chối mật khẩu dưới 6 ký tự; kiểm ở client để người dùng biết
    // ngay, không phải chờ một vòng gọi mạng.
    if (text.length < 6) return 'Mật khẩu cần ít nhất 6 ký tự.';
    return null;
  }

  static String? displayName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập tên của bạn.';
    if (text.length < 2) return 'Tên quá ngắn.';
    return null;
  }
}
