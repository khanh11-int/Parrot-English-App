import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Bottom sheet chọn sticker vẹt, dùng cho chat nhóm và bình luận.
///
/// Khớp với vật phẩm "Sticker vẹt" trong Cửa hàng. Trả về đường dẫn asset của
/// sticker đã chọn, hoặc `null` nếu người dùng đóng sheet.
Future<String?> showStickerPicker(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (_) => const StickerPicker(),
  );
}

class StickerPicker extends StatelessWidget {
  const StickerPicker({super.key});

  static const _columnCount = 4;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: AppSpacing.pagePadding,
              child: Text('Chọn sticker', style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: GridView.count(
                crossAxisCount: _columnCount,
                shrinkWrap: true,
                padding: AppSpacing.pagePadding,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                children: [
                  for (final sticker in AppAssets.allStickers)
                    _StickerTile(asset: sticker),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.leafLight,
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(asset),
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
