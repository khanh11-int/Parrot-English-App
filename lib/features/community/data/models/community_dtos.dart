import '../../../../core/constants/app_labels.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/community_entities.dart';

/// DTO của `GET /leaderboard`. Xem `docs/API_SPEC.md`.
class LeaderboardDto {
  const LeaderboardDto({
    required this.currentRankKey,
    required this.safeZoneEndRank,
    required this.entries,
  });

  final String currentRankKey;
  final int safeZoneEndRank;
  final List<LeaderboardEntryDto> entries;

  factory LeaderboardDto.fromJson(JsonMap json) {
    return LeaderboardDto(
      currentRankKey: json.readStringOrNull('current_rank') ?? '',
      safeZoneEndRank: json.readIntOr('safe_zone_end_rank', 0),
      entries: json
          .readObjectList('entries')
          .map(LeaderboardEntryDto.fromJson)
          .toList(growable: false),
    );
  }

  Leaderboard toEntity() => Leaderboard(
    currentRank: parseRank(currentRankKey),
    safeZoneEndRank: safeZoneEndRank,
    entries: entries.map((entry) => entry.toEntity()).toList(growable: false),
  );

  /// Backend gửi khoá hạng dạng `lower_canopy`. Khoá lạ thì lùi về hạng thấp
  /// nhất, để bảng xếp hạng vẫn hiện được thay vì lỗi cả trang.
  static ForestRank parseRank(String key) => switch (key) {
    'forest_floor' => ForestRank.forestFloor,
    'undergrowth' => ForestRank.undergrowth,
    'lower_canopy' => ForestRank.lowerCanopy,
    'mid_canopy' => ForestRank.midCanopy,
    'upper_canopy' => ForestRank.upperCanopy,
    'emergent' => ForestRank.emergent,
    _ => ForestRank.forestFloor,
  };
}

class LeaderboardEntryDto {
  const LeaderboardEntryDto({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.experience,
    required this.isCurrentUser,
  });

  final int rank;
  final String name;
  final String avatarUrl;
  final int experience;
  final bool isCurrentUser;

  factory LeaderboardEntryDto.fromJson(JsonMap json) => LeaderboardEntryDto(
    rank: json.readIntOr('rank', 0),
    name: json.readString('name'),
    avatarUrl: json.readStringOrNull('avatar_url') ?? '',
    experience: json.readIntOr('experience', 0),
    isCurrentUser: json.readBoolOr('is_current_user'),
  );

  LeaderboardEntry toEntity() => LeaderboardEntry(
    rank: rank,
    name: name,
    avatarAsset: avatarUrl,
    experience: experience,
    isCurrentUser: isCurrentUser,
  );
}

/// DTO của `GET /me/group`.
class StudyGroupDto {
  const StudyGroupDto({
    required this.name,
    required this.memberCount,
    required this.leaderName,
    required this.avatarUrl,
    required this.totalExperience,
    required this.daysRemaining,
  });

  final String name;
  final int memberCount;
  final String leaderName;
  final String avatarUrl;
  final int totalExperience;
  final int daysRemaining;

  factory StudyGroupDto.fromJson(JsonMap json) => StudyGroupDto(
    name: json.readString('name'),
    memberCount: json.readIntOr('member_count', 0),
    leaderName: json.readStringOrNull('leader_name') ?? '',
    avatarUrl: json.readStringOrNull('avatar_url') ?? '',
    totalExperience: json.readIntOr('total_experience', 0),
    daysRemaining: json.readIntOr('days_remaining', 0),
  );

  StudyGroup toEntity() => StudyGroup(
    id: name,
    name: name,
    memberCount: memberCount,
    leaderName: leaderName,
    avatarAsset: avatarUrl,
    totalExperience: totalExperience,
    daysRemaining: daysRemaining,
  );
}
