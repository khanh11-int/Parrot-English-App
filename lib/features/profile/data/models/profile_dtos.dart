import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/user_profile.dart';

/// DTO của `GET /me/profile`. Xem `docs/API_SPEC.md`.
class UserProfileDto {
  const UserProfileDto({
    required this.name,
    required this.avatarUrl,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.experience,
    required this.streakDays,
    required this.groupName,
    required this.recentPostCount,
  });

  final String name;

  /// Backend trả URL ảnh; bản mock dùng đường dẫn asset. UI xử lý cả hai.
  final String avatarUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final int experience;
  final int streakDays;
  final String? groupName;
  final int recentPostCount;

  factory UserProfileDto.fromJson(JsonMap json) {
    return UserProfileDto(
      name: json.readString('name'),
      avatarUrl: json.readStringOrNull('avatar_url') ?? '',
      postCount: json.readIntOr('post_count', 0),
      followerCount: json.readIntOr('follower_count', 0),
      followingCount: json.readIntOr('following_count', 0),
      experience: json.readIntOr('experience', 0),
      streakDays: json.readIntOr('streak_days', 0),
      groupName: json.readStringOrNull('group_name'),
      recentPostCount: json.readIntOr('recent_post_count', 0),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      name: name,
      avatarAsset: avatarUrl,
      postCount: postCount,
      followerCount: followerCount,
      followingCount: followingCount,
      experience: experience,
      streakDays: streakDays,
      groupName: groupName,
      recentPostCount: recentPostCount,
    );
  }
}
