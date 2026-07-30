import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Kiểu chữ của app. Xem mục 2.4 của `docs/UI_SPEC.md`.
///
/// Không đặt `fontSize` trực tiếp trong widget — dùng các style ở đây rồi
/// `copyWith` nếu cần đổi màu.
abstract final class AppTextStyles {
  /// Số XP lớn ("355", "568").
  static const displayNumber = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  /// Tiêu đề màn hình.
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Tiêu đề mục ("Tổng quan", "Mua ngay").
  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Từ tiếng Anh ("chair", "person").
  static const wordEnglish = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Phiên âm IPA.
  static const wordPhonetic = TextStyle(
    fontSize: 13,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  /// Nghĩa tiếng Việt.
  static const wordMeaning = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const body = TextStyle(fontSize: 14, color: AppColors.textPrimary);

  static const bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// "5 tháng trước", "8 thành viên".
  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}
