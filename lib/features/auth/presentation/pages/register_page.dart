import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

/// Trang tạo tài khoản mới.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateConfirm(String? value) {
    if ((value ?? '').isEmpty) return 'Vui lòng nhập lại mật khẩu.';
    if (value != _passwordController.text) {
      return 'Mật khẩu nhập lại chưa khớp.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        );

    if (!mounted) return;
    // Đăng ký xong là đã đăng nhập luôn, `GoRouter` tự đưa về trang chủ.
    if (result case AuthRejected(:final message)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.danger,
            duration: AppDurations.snackBar,
          ),
        );
      return;
    }

    // Chốt ngữ cảnh autofill — xem ghi chú ở `LoginPage._submit`.
    TextInput.finishAutofillContext();
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  // Bắt buộc khi ô có `autofillHints` — xem ghi chú ở
                  // `LoginPage`. Nhóm cả 4 ô lại thành một biểu mẫu để trình
                  // quản lý mật khẩu hiểu đây là form tạo tài khoản.
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.asset(AppAssets.stickerAwesome, height: 100),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Bắt đầu học cùng vẹt!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _nameController,
                          label: 'Tên của bạn',
                          icon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: AuthValidators.displayName,
                          autofillHints: const [AutofillHints.name],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: AuthValidators.email,
                          autofillHints: const [AutofillHints.email],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Mật khẩu',
                          hint: 'Ít nhất 6 ký tự',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                          validator: AuthValidators.password,
                          autofillHints: const [AutofillHints.newPassword],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          controller: _confirmController,
                          label: 'Nhập lại mật khẩu',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirm,
                          onSubmitted: _submit,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        PrimaryButton(
                          label: 'Tạo tài khoản',
                          isLoading: isBusy,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
