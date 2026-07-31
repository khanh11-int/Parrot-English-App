import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Thẻ lớn nền gradient, có **hoạ tiết cây rừng mờ** ở góc trên phải.
///
/// Mục 2.5 của `docs/UI_SPEC.md` yêu cầu hoạ tiết lá ở header và các thẻ lớn,
/// nhưng trước đây chưa có ảnh nên các thẻ chỉ có gradient trơn.
///
/// Hoạ tiết cố tình **tràn ra ngoài** góc thẻ rồi bị `ClipRRect` cắt: cây mọc
/// vào từ ngoài khung trông tự nhiên hơn một cái cây đặt gọn trong góc.
///
/// Hoạ tiết luôn được **nhuộm một màu** ([decorColor]) chứ không giữ màu gốc.
/// Ảnh cây gốc màu xanh lá, đặt lên thẻ gradient xanh rừng thì gần như vô hình —
/// đã dựng ảnh thật ra xem và không thấy gì. Nhuộm trắng trên nền đậm (hoặc
/// xanh đậm trên nền nhạt) cho ra một hình chìm rõ nét mà vẫn không giành chỗ
/// đọc của chữ.
class JungleCard extends StatelessWidget {
  const JungleCard({
    super.key,
    required this.child,
    this.gradient = AppColors.canopyGradient,
    this.decor = AppAssets.decorVines,
    this.decorWidth = 116,
    this.decorHeight = 164,
    this.decorOpacity = 0.16,
    this.decorColor = AppColors.bgBase,
    this.decorOffset = const Offset(-18, -24),
    this.padding = AppSpacing.cardPadding,
  });

  final Widget child;
  final Gradient gradient;

  /// Ảnh hoạ tiết; đặt `null` để dùng thẻ gradient trơn.
  final String? decor;

  final double decorWidth;

  /// Chiều cao hoạ tiết. Phải khai **tường minh**: `Positioned` chỉ có `top` và
  /// `right` nên con nhận ràng buộc lỏng, và `Image` chưa giải mã xong thì cao
  /// bằng 0 — hoạ tiết không vẽ gì cho tới khi ảnh về, rồi thẻ giật một nhịp.
  final double decorHeight;

  final double decorOpacity;

  /// Màu nhuộm hoạ tiết. Trắng cho thẻ nền đậm, xanh đậm cho thẻ nền nhạt.
  final Color decorColor;

  /// Lệch của hoạ tiết so với góc trên phải. Giá trị âm đẩy nó tràn ra ngoài.
  final Offset decorOffset;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final decorAsset = decor;

    return ClipRRect(
      borderRadius: AppRadius.cardLargeBorder,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            if (decorAsset != null)
              Positioned(
                top: decorOffset.dy,
                right: decorOffset.dx,
                child: Opacity(
                  opacity: decorOpacity,
                  child: Image.asset(
                    decorAsset,
                    width: decorWidth,
                    height: decorHeight,
                    fit: BoxFit.contain,
                    // `srcIn` giữ đúng hình dáng lá và thay toàn bộ màu — hợp
                    // vì ảnh đã có nền trong suốt.
                    color: decorColor,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
            // Không `Positioned`: đây là widget quyết định chiều cao của thẻ,
            // hoạ tiết chỉ vẽ đè lên nên không được ảnh hưởng kích thước.
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
