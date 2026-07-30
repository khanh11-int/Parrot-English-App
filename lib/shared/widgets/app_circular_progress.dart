import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Vòng tiến độ tròn, có thể đặt nội dung ở giữa (phần trăm, số từ, mascot).
///
/// Giá trị đổi thì chạy mượt từ giá trị cũ sang mới thay vì nhảy.
class AppCircularProgress extends StatelessWidget {
  const AppCircularProgress({
    super.key,
    required this.value,
    this.size = 56,
    this.strokeWidth = 5,
    this.color = AppColors.primary,
    this.trackColor = AppColors.neutral,
    this.child,
  });

  /// Tỉ lệ hoàn thành trong khoảng 0..1.
  final double value;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  /// Nội dung giữa vòng.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: AppDurations.normal,
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                color: color,
                backgroundColor: trackColor,
                strokeCap: StrokeCap.round,
              ),
            ),
            if (child != null)
              Padding(
                padding: EdgeInsets.all(strokeWidth + AppSpacing.xs),
                child: FittedBox(child: child),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vòng tiến độ kèm phần trăm ở giữa — dạng dùng nhiều nhất.
class PercentCircularProgress extends StatelessWidget {
  const PercentCircularProgress({
    super.key,
    required this.value,
    this.size = 56,
    this.color = AppColors.primary,
    this.trackColor = AppColors.neutral,
  });

  final double value;
  final double size;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return AppCircularProgress(
      value: value,
      size: size,
      color: color,
      trackColor: trackColor,
      child: Text(
        '${(value.clamp(0.0, 1.0) * 100).round()}%',
        style: AppTextStyles.bodyBold.copyWith(color: color),
      ),
    );
  }
}
