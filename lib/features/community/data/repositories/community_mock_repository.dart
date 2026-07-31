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
      id: 'neu',
      name: 'neu',
      memberCount: 8,
      leaderName: 'Hoang Duyen',
      avatarAsset: AppAssets.stickerLove,
      totalExperience: 355,
      daysRemaining: 7,
    );
  }

  // --- Nhom hoc tap ----------------------------------------------------
  // Ban mock chi tra du lieu co dinh; cac thao tac ghi la ham rong.

  @override
  Future<List<StudyGroupSummary>> getJoinableGroups() async {
    await Future<void>.delayed(_mockDelay);
    return const [
      StudyGroupSummary(
        id: 'neu',
        name: 'neu',
        leaderName: 'Hoang Duyen',
        memberCount: 8,
      ),
      StudyGroupSummary(
        id: 'k64',
        name: 'K64 - NEU',
        leaderName: 'Minh Anh',
        memberCount: 12,
      ),
    ];
  }

  @override
  Future<void> createGroup(String name) async {}

  @override
  Future<void> joinGroup(String groupId) async {}

  @override
  Future<void> leaveGroup() async {}

  // --- Chat nhom & binh luan -------------------------------------------

  @override
  Stream<List<ChatMessage>> watchGroupMessages(String groupId) =>
      Stream.value(const [
        ChatMessage(
          id: 'm1',
          authorId: 'sample-hoang-duyen',
          authorName: 'Hoang Duyen',
          timeAgo: '5 phut truoc',
          text: 'Ca nha hom nay hoc duoc bao nhieu tu roi?',
        ),
        ChatMessage(
          id: 'm2',
          authorId: 'test-uid',
          authorName: 'Cong Tinh',
          timeAgo: 'vua xong',
          text: 'Minh xong 8 tu chu de Suc khoe!',
          isMine: true,
        ),
      ]);

  @override
  Future<void> sendGroupMessage(
    String groupId, {
    String? text,
    String? stickerAsset,
  }) async {}
}
