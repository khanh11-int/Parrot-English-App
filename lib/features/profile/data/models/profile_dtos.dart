import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/user_profile.dart';

/// DTO của `GET /me/profile`. Xem `docs/API_SPEC.md`.
class UserProfileDto {
  const UserProfileDto({
    required this.name,
    required this.avatarUrl,
    required this.experience,
    required this.streakDays,
    required this.groupName,
  });

  final String name;

  /// Backend trả URL ảnh; bản mock dùng đường dẫn asset. UI xử lý cả hai.
  final String avatarUrl;
  final int experience;
  final int streakDays;
  final String? groupName;

  factory UserProfileDto.fromJson(JsonMap json) {
    return UserProfileDto(
      name: json.readString('name'),
      avatarUrl: json.readStringOrNull('avatar_url') ?? '',
      experience: json.readIntOr('experience', 0),
      streakDays: json.readIntOr('streak_days', 0),
      groupName: json.readStringOrNull('group_name'),
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      name: name,
      avatarAsset: avatarUrl,
      experience: experience,
      streakDays: streakDays,
      groupName: groupName,
    );
  }
}
