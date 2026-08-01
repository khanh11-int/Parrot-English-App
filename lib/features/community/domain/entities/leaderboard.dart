import '../../../../core/constants/app_labels.dart';

/// Một hàng trong bảng xếp hạng.
///
/// Nằm cùng file với [Leaderboard] vì một hàng không có nghĩa gì khi tách khỏi
/// bảng chứa nó — đây là quan hệ bộ phận, không phải hai khái niệm riêng.
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
