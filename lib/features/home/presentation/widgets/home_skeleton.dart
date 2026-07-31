import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_loading.dart';

/// Skeleton của trang chủ, dựng theo đúng bố cục thật (lời chào + số đếm →
/// banner → 2 thẻ mục tiêu → nhiệm vụ) để lúc dữ liệu về không bị nhảy layout.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: const [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 160, height: 22),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonBox(width: 110, height: 14),
                ],
              ),
            ),
            SkeletonBox(
              width: 130,
              height: 36,
              borderRadius: AppRadius.chipBorder,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        SkeletonBox(height: 128, borderRadius: AppRadius.cardLargeBorder),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: SkeletonBox(
                height: 132,
                borderRadius: AppRadius.cardLargeBorder,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: SkeletonBox(
                height: 132,
                borderRadius: AppRadius.cardLargeBorder,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        // "Hôm nay" + thẻ nhiệm vụ ngày.
        SkeletonBox(width: 100, height: 22),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 190, borderRadius: AppRadius.cardBorder),
        SizedBox(height: AppSpacing.xl),
        // "Hành trình" + thẻ tiến độ giáo trình.
        SkeletonBox(width: 110, height: 22),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 74, borderRadius: AppRadius.cardBorder),
      ],
    );
  }
}
