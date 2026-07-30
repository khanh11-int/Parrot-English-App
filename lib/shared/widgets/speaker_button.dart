import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Nút loa đọc từ tiếng Anh.
///
/// Vùng bấm cố định 44×44 theo yêu cầu khả năng tiếp cận, dù icon chỉ 20px.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    required this.onPressed,
    this.isPlaying = false,
  });

  final VoidCallback onPressed;

  /// Đang phát thì icon đổi và tô màu đậm hơn để người dùng biết đã bấm.
  final bool isPlaying;

  static const _tapTargetSize = 44.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _tapTargetSize,
      height: _tapTargetSize,
      child: Material(
        color: AppColors.primaryLight,
        borderRadius: AppRadius.chipBorder,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.chipBorder,
          child: AnimatedSwitcher(
            duration: AppDurations.fast,
            child: Icon(
              isPlaying ? Icons.volume_up_rounded : Icons.volume_up_outlined,
              key: ValueKey(isPlaying),
              size: 20,
              color: isPlaying ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
