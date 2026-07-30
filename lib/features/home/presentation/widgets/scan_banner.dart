import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Banner mời chụp ảnh học từ mới — cửa vào tính năng cốt lõi của app, nên đặt
/// ở vị trí cao nhất của trang chủ.
class ScanBanner extends StatelessWidget {
  const ScanBanner({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: AppRadius.cardLargeBorder,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(gradient: AppColors.canopyGradient),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              0,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Gửi ảnh học từ mới!',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const _SendPhotoChip(),
                    ],
                  ),
                ),
                Image.asset(AppAssets.mascotCamera, width: 96),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nhãn "Gửi ảnh" trong banner.
///
/// Không dùng nút thật: cả banner đã bấm được, thêm nút lồng trong vùng bấm sẽ
/// tạo hai vùng chạm chồng nhau gây khó bấm.
class _SendPhotoChip extends StatelessWidget {
  const _SendPhotoChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.chipBorder,
      ),
      child: Text(
        'Gửi ảnh',
        style: AppTextStyles.button.copyWith(color: AppColors.leafDark),
      ),
    );
  }
}
