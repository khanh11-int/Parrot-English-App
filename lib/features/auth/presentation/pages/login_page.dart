import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_providers.dart';

/// Trang đăng nhập bằng email + mật khẩu.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await ref
        .read(authControllerProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    // Đăng nhập xong `GoRouter` tự chuyển sang trang chủ nhờ redirect, nên ở
    // đây chỉ cần xử lý trường hợp thất bại.
    if (result case AuthRejected(:final message)) {
      if (!mounted) return;
      _showError(message);
    }
  }

  Future<void> _resetPassword() async {
    final emailError = AuthValidators.email(_emailController.text);
    if (emailError != null) {
      _showError('Nhập email của bạn trước đã, rồi bấm lại.');
      return;
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);
    if (!mounted) return;

    switch (result) {
      case AuthSucceeded():
        _showMessage('Đã gửi email đặt lại mật khẩu. Kiểm tra hộp thư nhé.');
      case AuthRejected(:final message):
        _showError(message);
    }
  }

  void _showError(String message) => _show(message, isError: true);

  void _showMessage(String message) => _show(message, isError: false);

  void _show(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.danger : null,
          duration: AppDurations.snackBar,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                // Kẹp bề rộng để trên máy rộng form không bị kéo dài quá xa.
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(AppAssets.stickerHello, height: 120),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Chào mừng trở lại!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Đăng nhập để tiếp tục học từ vựng',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: AppSpacing.xl),
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
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: AuthValidators.password,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: _submit,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isBusy ? null : _resetPassword,
                          child: const Text('Quên mật khẩu?'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      PrimaryButton(
                        label: 'Đăng nhập',
                        isLoading: isBusy,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _RegisterPrompt(
                        onPressed: isBusy
                            ? null
                            : () => context.push(AppRoutes.register),
                      ),
                    ],
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

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // `Wrap` chứ không phải `Row`: câu tiếng Việt cộng nhãn nút vừa đủ tràn ở
    // máy hẹp hoặc khi người dùng đặt cỡ chữ hệ thống lớn. `Wrap` cho xuống
    // dòng thay vì tràn khỏi màn hình.
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Chưa có tài khoản?', style: AppTextStyles.caption),
        TextButton(onPressed: onPressed, child: const Text('Đăng ký ngay')),
      ],
    );
  }
}
