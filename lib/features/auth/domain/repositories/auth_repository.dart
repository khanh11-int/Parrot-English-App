import '../entities/app_user.dart';

/// Nguồn xác thực người dùng.
abstract interface class AuthRepository {
  /// Người dùng hiện tại, `null` nếu chưa đăng nhập.
  ///
  /// Đọc **đồng bộ** để `GoRouter.redirect` quyết định được ngay có cho vào
  /// route hay không, không phải chờ future.
  AppUser? get currentUser;

  /// Phát ra mỗi lần thông tin người đăng nhập đổi — vào, ra, hết phiên, **và
  /// cả khi đổi tên hiển thị**.
  ///
  /// Phải phát cả lúc đổi tên: `signUp` gọi `updateDisplayName` **sau** khi tài
  /// khoản đã được tạo, nên nếu stream chỉ phát lúc vào/ra thì không chỗ nào
  /// biết tên đã có để đồng bộ xuống Firestore.
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

  /// Đổi tên hiển thị của người đang đăng nhập.
  ///
  /// Là nguồn sự thật của tên: [authStateChanges] phát lại sau khi đổi, và hồ sơ
  /// tự soi theo đó để cập nhật `users/{uid}.name` — chỗ mà bảng xếp hạng đọc.
  Future<void> updateDisplayName(String name);
}
