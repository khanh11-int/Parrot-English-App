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
  Future<void> createProfileIfMissing(AppUser user);
}
