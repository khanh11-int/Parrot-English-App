import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../providers/scan_providers.dart';

/// Chụp / chọn ảnh để nhận diện từ vựng — mục 5.2 của `docs/UI_SPEC.md`.
///
/// Chưa gắn camera thật (cần `camera` / `image_picker`), nên bản này dựng đủ
/// bố cục và luồng trạng thái: bấm chụp → đang xử lý (huỷ được) → sang trang
/// kết quả.
class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanControllerProvider);
    final errorMessage = scan.errorMessage;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _CameraPreviewPlaceholder(),
          SafeArea(
            child: Column(
              children: [
                const _ScanTopBar(),
                const Spacer(),
                if (errorMessage != null)
                  _ScanErrorBanner(message: errorMessage),
                _ScanControls(
                  onCapture: () => _recognize(context, ref),
                  onPickFromGallery: () => _recognize(context, ref),
                ),
              ],
            ),
          ),
          if (scan.isProcessing)
            _ProcessingOverlay(
              onCancel: () =>
                  ref.read(scanControllerProvider.notifier).cancel(),
            ),
        ],
      ),
    );
  }

  Future<void> _recognize(BuildContext context, WidgetRef ref) async {
    final hasResult = await ref
        .read(scanControllerProvider.notifier)
        .recognize();

    // Phải kiểm `mounted` sau `await`: người dùng có thể đã rời trang.
    if (!hasResult || !context.mounted) return;
    context.push(AppRoutes.scanResult);
  }
}

/// Khung xem trước camera. Thay bằng `CameraPreview` khi gắn camera thật.
class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF1A1A1A),
      child: Center(
        child: Icon(
          Icons.photo_camera_outlined,
          size: 64,
          color: Colors.white24,
        ),
      ),
    );
  }
}

class _ScanTopBar extends StatelessWidget {
  const _ScanTopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.bgBase,
            tooltip: 'Đóng',
          ),
          Expanded(
            child: Text(
              'Hướng máy vào vật muốn học từ',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(color: AppColors.bgBase),
            ),
          ),
          // Chừa chỗ đối xứng với nút đóng để tiêu đề nằm đúng giữa.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ScanControls extends StatelessWidget {
  const _ScanControls({
    required this.onCapture,
    required this.onPickFromGallery,
  });

  final VoidCallback onCapture;
  final VoidCallback onPickFromGallery;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CircleAction(
            icon: Icons.photo_library_outlined,
            tooltip: 'Chọn từ thư viện',
            onPressed: onPickFromGallery,
          ),
          _ShutterButton(onPressed: onCapture),
          const _CircleAction(
            icon: Icons.cameraswitch_outlined,
            tooltip: 'Đổi camera',
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Chụp ảnh',
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgBase,
            border: Border.all(color: AppColors.primary, width: 4),
          ),
          child: const Icon(
            Icons.photo_camera_rounded,
            color: AppColors.primary,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      iconSize: 24,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white24,
        disabledBackgroundColor: Colors.white10,
        foregroundColor: AppColors.bgBase,
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

/// Overlay lúc đang gọi AI. Luôn có nút Huỷ vì AI có thể chậm hoặc treo.
class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.mascotTeacher, width: 120),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Đang đọc ảnh...',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.bgBase,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SecondaryButton(
              label: AppLabels.cancel,
              onPressed: onCancel,
              isExpanded: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanErrorBanner extends StatelessWidget {
  const _ScanErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: AppRadius.buttonBorder,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
