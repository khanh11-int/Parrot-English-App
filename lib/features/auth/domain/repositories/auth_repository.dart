import '../entities/app_user.dart';

/// Nguồn xác thực người dùng.
abstract interface class AuthRepository {
  /// Người dùng hiện tại, `null` nếu chưa đăng nhập.
  ///
  /// Đọc **đồng bộ** để `GoRouter.redirect` quyết định được ngay có cho vào
  /// route hay không, không phải chờ future.
  AppUser? get currentUser;

  /// Phát ra mỗi lần trạng thái đăng nhập đổi (vào, ra, hết phiên).
  Stream<AppUser?> authStateChanges();

  /// Đăng nhập bằng email + mật khẩu. Ném `AuthFailure` nếu thất bại.
  Future<void> signIn({required String email, required String password});

  /// Tạo tài khoản mới rồi đăng nhập luôn.
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();

  /// Gửi email đặt lại mật khẩu.
  Future<void> sendPasswordReset(String email);
}
