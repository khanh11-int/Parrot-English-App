import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_dtos.dart';

/// Lấy trang cá nhân từ REST API.
class ProfileRemoteRepository implements ProfileRepository {
  const ProfileRemoteRepository(this._client);

  final ApiClient _client;

  // Với backend REST, hồ sơ do server tự tạo lúc đăng ký nên client không phải
  // làm gì. Giữ hàm rỗng để thoả interface.
  @override
  Future<void> ensureProfile(AppUser user) async {}

  @override
  Future<UserProfile> getProfile() async {
    final json = await _client.getObject(ApiEndpoints.profile);
    return UserProfileDto.fromJson(json).toEntity();
  }
}
