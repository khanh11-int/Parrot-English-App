import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Thanh tiến độ bo tròn, cao 8. Giá trị đổi thì chạy mượt từ giá trị cũ sang
/// giá trị mới thay vì nhảy.
class AppLinearProgress extends StatelessWidget {
  const AppLinearProgress({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.neutral,
    this.height = 8,
  });

  /// Tỉ lệ hoàn thành trong khoảng 0..1.
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: animatedValue,
          minHeight: height,
          color: color,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}
