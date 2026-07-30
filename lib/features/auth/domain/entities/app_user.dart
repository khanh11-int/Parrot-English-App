/// Người dùng đã đăng nhập.
///
/// Chỉ giữ những gì UI cần. Cố tình **không** dùng trực tiếp `User` của
/// `firebase_auth` ở tầng trên: đổi nhà cung cấp xác thực về sau sẽ không phải
/// sửa UI.
class AppUser {
  const AppUser({required this.id, required this.email, this.displayName});

  /// `uid` của Firebase Auth — cũng là id document trong `users/{uid}`.
  final String id;
  final String email;
  final String? displayName;

  /// Tên để chào ở trang chủ. Chưa đặt tên thì lấy phần trước `@` của email.
  String get greetingName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return email.split('@').first;
  }
}
