import '../../../../core/constants/app_labels.dart';

/// Một từ vựng nhúng trong bài đăng, người xem có thể lưu về bộ từ của mình.
class SharedWord {
  const SharedWord({
    required this.english,
    required this.vietnamese,
    required this.phonetic,
  });

  final String english;
  final String vietnamese;
  final String phonetic;
}

/// Một bài đăng trên dòng thời gian.
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatarAsset,
    required this.timeAgo,
    required this.sharedWord,
    required this.detectedLabel,
    this.likeCount = 0,
    this.commentCount = 0,
    this.bookmarkCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  final String id;
  final String authorName;
  final String authorAvatarAsset;

  /// Chuỗi thời gian đã định dạng sẵn ("5 tháng trước").
  ///
  /// Định dạng ở tầng data thay vì lưu `DateTime` để UI không phải mang logic
  /// tính thời gian tương đối.
  final String timeAgo;
  final SharedWord sharedWord;

  /// Nhãn nhận diện hiện trên ảnh, ví dụ `chair - cái ghế 1.00`.
  final String detectedLabel;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final bool isLiked;
  final bool isBookmarked;

  CommunityPost copyWith({
    int? likeCount,
    int? bookmarkCount,
    bool? isLiked,
    bool? isBookmarked,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      authorAvatarAsset: authorAvatarAsset,
      timeAgo: timeAgo,
      sharedWord: sharedWord,
      detectedLabel: detectedLabel,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

/// Một hàng trong bảng xếp hạng.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.avatarAsset,
    required this.experience,
    this.isCurrentUser = false,
  });

  final int rank;
  final String name;
  final String avatarAsset;
  final int experience;

  /// Hàng của chính người dùng → tô nền và ghim khi cuộn.
  final bool isCurrentUser;
}

/// Bảng xếp hạng tuần, kèm mốc ranh giới giữ hạng.
class Leaderboard {
  const Leaderboard({
    required this.currentRank,
    required this.entries,
    required this.safeZoneEndRank,
  });

  /// Hạng (tầng rừng) mà giải đấu hiện tại đang ở.
  final ForestRank currentRank;
  final List<LeaderboardEntry> entries;

  /// Hạng cuối cùng còn nằm trong vùng an toàn (không bị xuống hạng).
  final int safeZoneEndRank;
}

/// Nhóm học tập của người dùng.
class StudyGroup {
  const StudyGroup({
    required this.name,
    required this.memberCount,
    required this.leaderName,
    required this.avatarAsset,
    required this.totalExperience,
    required this.daysRemaining,
  });

  final String name;
  final int memberCount;
  final String leaderName;
  final String avatarAsset;

  /// XP tích luỹ của cả nhóm.
  final int totalExperience;

  /// Số ngày còn lại của mùa hiện tại.
  final int daysRemaining;

  /// Mốc cao nhất nhóm đã đạt; `null` nếu chưa đạt mốc nào.
  GroupMilestone? get achievedMilestone {
    GroupMilestone? result;
    for (final milestone in GroupMilestone.values) {
      if (totalExperience >= milestone.requiredExperience) result = milestone;
    }
    return result;
  }

  /// Mốc nhóm đang hướng tới; `null` nếu đã đạt hết.
  GroupMilestone? get currentMilestone {
    for (final milestone in GroupMilestone.values) {
      if (totalExperience < milestone.requiredExperience) return milestone;
    }
    return null;
  }

  bool isMilestoneUnlocked(GroupMilestone milestone) =>
      totalExperience >= milestone.requiredExperience;
}
