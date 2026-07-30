import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_labels.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'secondary_button.dart';

/// Trạng thái lỗi: mascot buồn + câu ngắn tiếng Việt + nút thử lại.
///
/// Không hiện nội dung exception thô cho người dùng — thông báo kỹ thuật để
/// trong log, người dùng chỉ cần biết phải làm gì tiếp.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    this.message = 'Có lỗi xảy ra. Vui lòng thử lại.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.stickerSad, width: 120),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SecondaryButton(
                label: AppLabels.retry,
                onPressed: onRetry,
                isExpanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
