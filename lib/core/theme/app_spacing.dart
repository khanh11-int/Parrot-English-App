import 'package:flutter/widgets.dart';

/// Khoảng cách theo bậc 4px. Xem mục 2.2 của `UI_SPEC.md`.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Lề ngang mặc định của mọi trang.
  static const pagePadding = EdgeInsets.symmetric(horizontal: lg);

  /// Khoảng cách giữa 2 thẻ trong danh sách.
  static const cardGap = md;

  /// Padding bên trong một thẻ.
  static const cardPadding = EdgeInsets.all(lg);
}

/// Bán kính bo góc. Xem mục 2.3 của `UI_SPEC.md`.
abstract final class AppRadius {
  /// Viên thuốc (chip, pill).
  static const chip = 999.0;
  static const card = 16.0;
  static const cardLarge = 24.0;
  static const button = 12.0;
  static const image = 12.0;

  static const chipBorder = BorderRadius.all(Radius.circular(chip));
  static const cardBorder = BorderRadius.all(Radius.circular(card));
  static const cardLargeBorder = BorderRadius.all(Radius.circular(cardLarge));
  static const buttonBorder = BorderRadius.all(Radius.circular(button));
  static const imageBorder = BorderRadius.all(Radius.circular(image));
}

/// Thời lượng animation. Giữ trong khoảng 200–300ms (mục 7 `UI_SPEC.md`).
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);

  /// Thời gian hiện phản hồi sai trước khi bỏ chọn.
  static const wrongAnswerFlash = Duration(milliseconds: 300);

  /// SnackBar thành công.
  static const snackBar = Duration(seconds: 2);
}
