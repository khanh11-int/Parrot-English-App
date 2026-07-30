import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../domain/entities/community_entities.dart';
import '../../domain/repositories/community_repository.dart';

/// Dữ liệu mock, dùng khi chưa khai báo `PARROT_API_BASE_URL`.
///
/// Giữ lại để người làm UI không bị chặn khi backend chưa xong, và để test
/// widget chạy được mà không cần server.
class CommunityMockRepository implements CommunityRepository {
  const CommunityMockRepository();

  static const _mockDelay = Duration(milliseconds: 500);

  @override
  Future<List<CommunityPost>> getFeed() async {
    await Future<void>.delayed(_mockDelay);

    return const [
      CommunityPost(
        id: 'post-1',
        authorName: 'K64 - NEU',
        authorAvatarAsset: AppAssets.stickerHello,
        timeAgo: '5 tháng trước',
        sharedWord: SharedWord(
          english: 'person',
          vietnamese: 'người',
          phonetic: '/ˈpɜː.sən/',
        ),
        detectedLabel: 'chair - cái ghế 1.00',
        likeCount: 4,
        commentCount: 0,
        bookmarkCount: 0,
      ),
      CommunityPost(
        id: 'post-2',
        authorName: 'Hoang Duyen',
        authorAvatarAsset: AppAssets.stickerHappy,
        timeAgo: '2 ngày trước',
        sharedWord: SharedWord(
          english: 'kitchen',
          vietnamese: 'nhà bếp',
          phonetic: '/ˈkɪtʃ.ən/',
        ),
        detectedLabel: 'sink - bồn rửa 0.96',
        likeCount: 12,
        commentCount: 3,
        bookmarkCount: 2,
        isLiked: true,
      ),
      CommunityPost(
        id: 'post-3',
        authorName: 'Công Tình',
        authorAvatarAsset: AppAssets.stickerAwesome,
        timeAgo: '1 tuần trước',
        sharedWord: SharedWord(
          english: 'backpack',
          vietnamese: 'ba lô',
          phonetic: '/ˈbæk.pæk/',
        ),
        detectedLabel: 'backpack - ba lô 0.99',
        likeCount: 7,
        commentCount: 1,
        bookmarkCount: 5,
      ),
    ];
  }

  @override
  Future<Leaderboard> getLeaderboard() async {
    await Future<void>.delayed(_mockDelay);

    return const Leaderboard(
      currentRank: ForestRank.lowerCanopy,
      safeZoneEndRank: 6,
      entries: [
        LeaderboardEntry(
          rank: 1,
          name: 'Minh Anh',
          avatarAsset: AppAssets.stickerAwesome,
          experience: 312,
        ),
        LeaderboardEntry(
          rank: 2,
          name: 'Hoang Duyen',
          avatarAsset: AppAssets.stickerHappy,
          experience: 264,
        ),
        LeaderboardEntry(
          rank: 3,
          name: 'Thu Hà',
          avatarAsset: AppAssets.stickerLove,
          experience: 198,
        ),
        LeaderboardEntry(
          rank: 4,
          name: 'Lê Hồng',
          avatarAsset: AppAssets.stickerHello,
          experience: 154,
        ),
        LeaderboardEntry(
          rank: 5,
          name: 'Lê Cường',
          avatarAsset: AppAssets.stickerThinking,
          experience: 129,
        ),
        LeaderboardEntry(
          rank: 6,
          name: 'Bá Đức',
          avatarAsset: AppAssets.stickerSurprised,
          experience: 122,
        ),
        LeaderboardEntry(
          rank: 7,
          name: 'Công Tình',
          avatarAsset: AppAssets.stickerCheer,
          experience: 98,
          isCurrentUser: true,
        ),
        LeaderboardEntry(
          rank: 8,
          name: 'Quốc Bảo',
          avatarAsset: AppAssets.stickerTired,
          experience: 74,
        ),
      ],
    );
  }

  /// Nhóm học tập của người dùng; `null` nếu chưa tham gia nhóm nào.
  @override
  Future<StudyGroup?> getStudyGroup() async {
    await Future<void>.delayed(_mockDelay);

    return const StudyGroup(
      name: 'neu',
      memberCount: 8,
      leaderName: 'Hoang Duyen',
      avatarAsset: AppAssets.stickerLove,
      totalExperience: 355,
      daysRemaining: 7,
    );
  }

  // Bản mock không lưu trạng thái giữa các lần gọi, nên chỉ dựng lại bài đăng
  // với cờ mới. Provider giữ state thật trong bộ nhớ.
  @override
  Future<CommunityPost> setLiked(String postId, {required bool isLiked}) async {
    final post = await _findPost(postId);
    return post.copyWith(
      isLiked: isLiked,
      likeCount: post.likeCount + (isLiked ? 1 : -1),
    );
  }

  @override
  Future<CommunityPost> setBookmarked(
    String postId, {
    required bool isBookmarked,
  }) async {
    final post = await _findPost(postId);
    return post.copyWith(
      isBookmarked: isBookmarked,
      bookmarkCount: post.bookmarkCount + (isBookmarked ? 1 : -1),
    );
  }

  Future<CommunityPost> _findPost(String postId) async {
    final posts = await getFeed();
    return posts.firstWhere((post) => post.id == postId);
  }
}
