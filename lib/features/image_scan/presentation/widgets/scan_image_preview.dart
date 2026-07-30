import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recognized_word.dart';
import 'detection_overlay.dart';

/// Ảnh đã chụp kèm lớp khung nhận diện và nút bật/tắt khung.
class ScanImagePreview extends StatelessWidget {
  const ScanImagePreview({
    super.key,
    required this.imagePath,
    required this.words,
    required this.areBoxesVisible,
    required this.onToggleBoxes,
    required this.onWordTap,
    this.highlightedWordId,
  });

  final String? imagePath;
  final List<RecognizedWord> words;
  final bool areBoxesVisible;
  final VoidCallback onToggleBoxes;
  final ValueChanged<RecognizedWord> onWordTap;
  final String? highlightedWordId;

  /// Tỉ lệ khung ảnh cố định để layout không nhảy trong lúc ảnh đang tải.
  static const _aspectRatio = 4 / 3;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.cardBorder,
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ImageOrPlaceholder(imagePath: imagePath),
            if (areBoxesVisible)
              DetectionOverlay(
                words: words,
                onWordTap: onWordTap,
                highlightedWordId: highlightedWordId,
              ),
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: _ToggleBoxesButton(
                areBoxesVisible: areBoxesVisible,
                onPressed: onToggleBoxes,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageOrPlaceholder extends StatelessWidget {
  const _ImageOrPlaceholder({required this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path == null) return const _MockImagePlaceholder();

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      // Ảnh do người dùng chọn có thể đã bị xoá/di chuyển → không để crash.
      errorBuilder: (_, _, _) => const _MockImagePlaceholder(),
    );
  }
}

/// Khung ảnh giả dùng khi chạy dữ liệu mock (chưa gắn camera thật).
class _MockImagePlaceholder extends StatelessWidget {
  const _MockImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.neutral,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_outlined,
              size: 40,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Ảnh mẫu', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _ToggleBoxesButton extends StatelessWidget {
  const _ToggleBoxesButton({
    required this.areBoxesVisible,
    required this.onPressed,
  });

  final bool areBoxesVisible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: AppRadius.chipBorder,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.chipBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                areBoxesVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 16,
                color: AppColors.bgBase,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                areBoxesVisible ? 'Ẩn khung' : 'Hiện khung',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.bgBase,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
