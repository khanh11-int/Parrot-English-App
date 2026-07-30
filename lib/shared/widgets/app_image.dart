import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Ảnh có nguồn đến từ **dữ liệu** (avatar, icon vật phẩm), nên có thể là URL
/// khi chạy với API thật hoặc đường dẫn asset khi chạy mock.
///
/// Widget này chọn `Image.network` hay `Image.asset` dựa vào nguồn, nên UI không
/// phải biết đang chạy chế độ nào. Ảnh nào chắc chắn nằm trong app (mascot,
/// sticker) thì dùng `Image.asset` trực tiếp cho gọn.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  /// URL `http(s)://...` hoặc đường dẫn asset `assets/images/...`.
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;

  bool get _isNetwork =>
      source.startsWith('http://') || source.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (source.isEmpty) return _fallback();

    if (_isNetwork) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        // Ảnh lỗi hoặc chưa tải xong không được làm sập trang hay nhảy layout.
        errorBuilder: (_, _, _) => _fallback(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _fallback(),
      );
    }

    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: AppColors.neutral,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 16,
            color: AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
