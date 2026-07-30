import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/recognized_word.dart';

/// Lớp khung nhận diện vẽ đè lên ảnh.
///
/// Toạ độ khung là tỉ lệ 0..1 nên dùng [LayoutBuilder] để đổi sang pixel theo
/// kích thước hiển thị thật — nhờ vậy khung luôn khớp dù ảnh co giãn.
class DetectionOverlay extends StatelessWidget {
  const DetectionOverlay({
    super.key,
    required this.words,
    required this.onWordTap,
    this.highlightedWordId,
  });

  final List<RecognizedWord> words;
  final ValueChanged<RecognizedWord> onWordTap;

  /// Khung của từ đang được chọn ở danh sách bên dưới → tô đậm hơn.
  final String? highlightedWordId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            for (final word in words)
              _DetectionBox(
                word: word,
                rect: word.boundingBox.scaleTo(width, height),
                isHighlighted: word.id == highlightedWordId,
                onTap: () => onWordTap(word),
              ),
          ],
        );
      },
    );
  }
}

class _DetectionBox extends StatelessWidget {
  const _DetectionBox({
    required this.word,
    required this.rect,
    required this.isHighlighted,
    required this.onTap,
  });

  final RecognizedWord word;
  final ({double left, double top, double width, double height}) rect;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isHighlighted ? AppColors.sun : AppColors.primary;

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: isHighlighted ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: _DetectionLabel(text: word.overlayLabel, color: borderColor),
          ),
        ),
      ),
    );
  }
}

/// Nhãn `từ độ-tin-cậy` gắn ở góc trên của khung.
class _DetectionLabel extends StatelessWidget {
  const _DetectionLabel({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.xs),
          bottomRight: Radius.circular(AppSpacing.xs),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textOnPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
