import '../../../auth/domain/entities/app_user.dart';
import '../entities/user_profile.dart';

/// Nguồn dữ liệu trang cá nhân.
abstract interface class ProfileRepository {
  /// Hồ sơ của người dùng đang đăng nhập. Ném `Failure` nếu thất bại.
  Future<UserProfile> getProfile();

  /// Tạo hồ sơ cho người dùng mới nếu chưa có.
  ///
  /// Gọi sau mỗi lần đăng nhập/đăng ký thành công, nên phải **idempotent**:
  /// đã có hồ sơ thì không ghi đè, tránh làm mất XP và streak.
  /// Tạo `users/{uid}` nếu chưa có, **và** đồng bộ tên hiển thị vào đó.
  ///
  /// Phải làm cả hai vì `signUp` đặt tên **sau** khi tài khoản được tạo: lúc
  /// document được ghi lần đầu, `displayName` còn rỗng nên tên lưu xuống là phần
  /// trước `@` của email. Bảng xếp hạng đọc `users/{uid}.name` nên nếu không
  /// đồng bộ lại thì cả bảng hiện email của nhau.
  Future<void> ensureProfile(AppUser user);
}
