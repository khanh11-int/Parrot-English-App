import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Dữ liệu mock, dùng khi chưa khai báo `PARROT_API_BASE_URL`.
///
/// Giữ lại để người làm UI không bị chặn khi backend chưa xong, và để test
/// widget chạy được mà không cần server.
class ProfileMockRepository implements ProfileRepository {
  const ProfileMockRepository();

  static const _mockDelay = Duration(milliseconds: 450);

  // Ban mock khong co noi nao de ghi, nen day chi la ham rong.
  @override
  Future<void> createProfileIfMissing(AppUser user) async {}

  @override
  Future<UserProfile> getProfile() async {
    await Future<void>.delayed(_mockDelay);

    return const UserProfile(
      name: 'Công Tình',
      // Rỗng như tài khoản thật chưa đặt ảnh: `RankAvatar` dùng huy hiệu hạng.
      // 568 XP là hạng Bụi Rậm nên hiện `ranks/level-2.png`.
      avatarAsset: '',
      followerCount: 1,
      followingCount: 5,
      experience: 568,
      streakDays: 1,
      groupName: 'neu',
    );
  }
}
