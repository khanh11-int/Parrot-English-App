import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Khối xám nhấp nháy nhẹ, dùng dựng skeleton theo đúng hình dạng nội dung sắp
/// hiện ra. Ưu tiên cách này hơn spinner giữa trang: người dùng thấy trước bố
/// cục nên cảm giác chờ ngắn hơn.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = AppRadius.buttonBorder,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.45,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.neutral,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

/// Skeleton mặc định dạng danh sách thẻ, dùng khi chưa biết nội dung cụ thể.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.cardGap),
      itemBuilder: (_, _) =>
          const SkeletonBox(height: 88, borderRadius: AppRadius.cardBorder),
    );
  }
}
