import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/user_profile.dart';

/// DTO của `GET /me/profile`. Xem `docs/API_SPEC.md`.
class UserProfileDto {
  const UserProfileDto({
    required this.name,
    required this.avatarUrl,
    required this.followerCount,
    required this.followingCount,
    required this.experience,
    required this.streakDays,
    required this.groupName,
  });

  final String name;

  /// Backend trả URL ảnh; bản mock dùng đường dẫn asset. UI xử lý cả hai.
  final String avatarUrl;
  final int followerCount;
  final int followingCount;
  final int experience;
  final int streakDays;
  final String? groupName;

  factory UserProfileDto.fromJson(JsonMap json) {
    return UserProfileDto(
      name: json.readString('name'),
      avatarUrl: json.readStringOrNull('avatar_url') ?? '',
      followerCount: json.readIntOr('follower_count', 0),
      followingCount: json.readIntOr('following_count', 0),
      experience: json.readIntOr('experience', 0),
      streakDays: json.readIntOr('streak_days', 0),
      groupName: json.readStringOrNull('group_name'),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      name: name,
      avatarAsset: avatarUrl,
      followerCount: followerCount,
      followingCount: followingCount,
      experience: experience,
      streakDays: streakDays,
      groupName: groupName,
    );
  }
}
