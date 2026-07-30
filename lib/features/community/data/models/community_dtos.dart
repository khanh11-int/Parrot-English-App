import '../../../../core/constants/app_labels.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/community_entities.dart';

/// DTO của `GET /feed` và các endpoint like/bookmark. Xem `API_SPEC.md`.
class CommunityPostDto {
  const CommunityPostDto({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timeAgo,
    required this.sharedWord,
    required this.detectedLabel,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    required this.isLiked,
    required this.isBookmarked,
  });

  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String timeAgo;
  final SharedWordDto sharedWord;
  final String detectedLabel;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final bool isLiked;
  final bool isBookmarked;

  factory CommunityPostDto.fromJson(JsonMap json) {
    return CommunityPostDto(
      id: json.readString('id'),
      authorName: json.readString('author_name'),
      authorAvatarUrl: json.readStringOrNull('author_avatar_url') ?? '',
      // Backend định dạng sẵn chuỗi thời gian tương đối để app không phải mang
      // logic tính "5 tháng trước" và không lệch do lệch giờ máy.
      timeAgo: json.readStringOrNull('time_ago') ?? '',
      sharedWord: SharedWordDto.fromJson(json.readObject('shared_word')),
      detectedLabel: json.readStringOrNull('detected_label') ?? '',
      likeCount: json.readIntOr('like_count', 0),
      commentCount: json.readIntOr('comment_count', 0),
      bookmarkCount: json.readIntOr('bookmark_count', 0),
      isLiked: json.readBoolOr('is_liked'),
      isBookmarked: json.readBoolOr('is_bookmarked'),
    );
  }

  CommunityPost toEntity() => CommunityPost(
    id: id,
    authorName: authorName,
    authorAvatarAsset: authorAvatarUrl,
    timeAgo: timeAgo,
    sharedWord: sharedWord.toEntity(),
    detectedLabel: detectedLabel,
    likeCount: likeCount,
    commentCount: commentCount,
    bookmarkCount: bookmarkCount,
    isLiked: isLiked,
    isBookmarked: isBookmarked,
  );
}

class SharedWordDto {
  const SharedWordDto({
    required this.english,
    required this.vietnamese,
    required this.phonetic,
  });

  final String english;
  final String vietnamese;
  final String phonetic;

  factory SharedWordDto.fromJson(JsonMap json) => SharedWordDto(
    english: json.readString('english'),
    vietnamese: json.readString('vietnamese'),
    phonetic: json.readStringOrNull('phonetic') ?? '',
  );

  SharedWord toEntity() =>
      SharedWord(english: english, vietnamese: vietnamese, phonetic: phonetic);
}

/// DTO của `GET /leaderboard`.
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
    name: name,
    memberCount: memberCount,
    leaderName: leaderName,
    avatarAsset: avatarUrl,
    totalExperience: totalExperience,
    daysRemaining: daysRemaining,
  );
}
