import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/currency_pill.dart';

/// Đầu trang chủ: lời chào bên trái, ba số đếm bên phải.
///
/// Lời chào để trang có điểm neo cho mắt thay vì mở ra là một hàng số trơ trọi.
class CurrencyHeader extends StatelessWidget {
  const CurrencyHeader({
    super.key,
    required this.userName,
    required this.streakDays,
    required this.gemCount,
    required this.seedCount,
    this.onShopPressed,
  });

  final String userName;
  final int streakDays;
  final int gemCount;
  final int seedCount;
  final VoidCallback? onShopPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào $userName 👋',
                    style: AppTextStyles.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text('Hôm nay học gì nhỉ?', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CurrencyGroup(
              streakDays: streakDays,
              gemCount: gemCount,
              seedCount: seedCount,
              onShopPressed: onShopPressed,
            ),
          ],
        ),
      ],
    );
  }
}

/// Ba số đếm gom trong một khối nền trắng bo tròn, để chúng thành một nhóm rõ
/// ràng chứ không lẫn vào nền trang.
class _CurrencyGroup extends StatelessWidget {
  const _CurrencyGroup({
    required this.streakDays,
    required this.gemCount,
    required this.seedCount,
    required this.onShopPressed,
  });

  final int streakDays;
  final int gemCount;
  final int seedCount;
  final VoidCallback? onShopPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        borderRadius: AppRadius.chipBorder,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyPill(kind: CurrencyKind.streak, amount: streakDays),
          CurrencyPill(
            kind: CurrencyKind.gem,
            amount: gemCount,
            onTap: onShopPressed,
          ),
          CurrencyPill(
            kind: CurrencyKind.seed,
            amount: seedCount,
            onTap: onShopPressed,
          ),
        ],
      ),
    );
  }
}
