import 'package:flutter/material.dart';

/// Bảng màu của app — chủ đề **rừng rậm nhiệt đới**.
///
/// Xem mục 2.1 của `docs/UI_SPEC.md`. Mọi widget phải lấy màu từ đây, không viết
/// `Color(0x...)` rải rác, để đổi bảng màu chỉ cần sửa một chỗ.
abstract final class AppColors {
  // --- Thương hiệu ------------------------------------------------------
  /// Giữ xanh dương vì khớp bộ lông cánh của mascot vẹt.
  static const primary = Color(0xFF2E6BE6);
  static const primaryDark = Color(0xFF1F4FBF);
  static const primaryLight = Color(0xFFE8F0FE);

  // --- Rừng (màu phụ: gradient, hoạ tiết, huy hiệu) ---------------------
  static const leaf = Color(0xFF43B02A);
  static const leafDark = Color(0xFF2E7D22);
  static const leafLight = Color(0xFFE7F6E3);
  static const canopy = Color(0xFF1B5E3A);
  static const sun = Color(0xFFFFC93C);

  // --- Nền --------------------------------------------------------------
  static const bgBase = Color(0xFFFFFFFF);
  static const bgSoft = Color(0xFFF5FAF3);
  static const bgGradientTop = Color(0xFFEAF7E6);

  /// Gradient nền của các trang gốc: xanh lá rất nhạt đổ xuống trắng.
  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgGradientTop, bgBase],
  );

  /// Gradient cho banner và header nhóm — tán rừng.
  static const canopyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leaf, canopy],
  );

  // --- Ngữ nghĩa --------------------------------------------------------
  // `success` chỉ dùng cho phản hồi đúng/sai trong bài học. Trang trí theo
  // chủ đề rừng phải dùng `leaf`, nếu trộn lẫn người học sẽ tưởng thẻ trang
  // trí là "đáp án đúng".
  static const success = Color(0xFF7FD69B);
  static const successSoft = Color(0xFFDFF5E6);
  static const danger = Color(0xFFE5534B);
  static const dangerSoft = Color(0xFFFDECEA);
  static const warning = Color(0xFFFFB020);
  static const neutral = Color(0xFFEEF0F4);

  // --- Chữ --------------------------------------------------------------
  static const textPrimary = Color(0xFF1B2430);
  static const textSecondary = Color(0xFF6B7684);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textDisabled = Color(0xFFA7B0BD);

  // --- Đường kẻ ---------------------------------------------------------
  static const divider = Color(0xFFE4E8EF);

  // --- Tiền tệ ----------------------------------------------------------
  /// "Hạt" — tiền mềm, kiếm bằng học tập.
  static const coinSeed = Color(0xFFD99A2B);

  /// "Ngọc" lục bảo — tiền cứng.
  static const coinGem = Color(0xFF17B978);

  /// Streak (ngọn lửa).
  static const streak = warning;
}
