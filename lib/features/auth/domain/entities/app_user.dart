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

  /// So sánh **theo giá trị**, không theo tham chiếu.
  ///
  /// Cần thiết vì stream xác thực dùng `userChanges()` — nó phát cả khi token
  /// được làm mới (mỗi giờ), mỗi lần tạo một `AppUser` mới. Không có `==` theo
  /// giá trị thì Riverpod coi đó là dữ liệu đổi và mọi provider đọc người dùng
  /// hiện tại sẽ tải lại, dù chẳng có gì khác.
  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(id, email, displayName);
}
