import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/entities/study_group_summary.dart';
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

    // `avatarAsset` để rỗng: bản mock cũng đi qua đúng đường của dữ liệu thật,
    // tức `RankAvatar` chọn huy hiệu theo hạng. Gán sticker cứng ở đây thì test
    // và bản dev sẽ không bao giờ chạm tới nhánh huy hiệu.
    //
    // XP trải qua 3 hạng để thấy avatar đổi: 1290 là Bụi Rậm, 300 là Thảm Rừng.
    return const Leaderboard(
      currentRank: ForestRank.lowerCanopy,
      safeZoneEndRank: 4,
      entries: [
        LeaderboardEntry(
          rank: 1,
          name: 'Minh Anh',
          avatarAsset: '',
          experience: 3120,
        ),
        LeaderboardEntry(
          rank: 2,
          name: 'Hoang Duyen',
          avatarAsset: '',
          experience: 2640,
        ),
        LeaderboardEntry(
          rank: 3,
          name: 'Thu Hà',
          avatarAsset: '',
          experience: 1980,
        ),
        LeaderboardEntry(
          rank: 4,
          name: 'Lê Hồng',
          avatarAsset: '',
          experience: 1540,
        ),
        LeaderboardEntry(
          rank: 5,
          name: 'Lê Cường',
          avatarAsset: '',
          experience: 1290,
        ),
        LeaderboardEntry(
          rank: 6,
          name: 'Công Tình',
          avatarAsset: '',
          experience: 300,
          isCurrentUser: true,
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
