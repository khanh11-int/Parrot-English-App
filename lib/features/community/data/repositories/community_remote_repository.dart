import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/community_entities.dart';
import '../../domain/repositories/community_repository.dart';
import '../models/community_dtos.dart';

/// Dữ liệu Cộng đồng lấy từ REST API.
class CommunityRemoteRepository implements CommunityRepository {
  const CommunityRemoteRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<CommunityPost>> getFeed() async {
    final items = await _client.getList(ApiEndpoints.feed);
    return items
        .map((json) => CommunityPostDto.fromJson(json).toEntity())
        .toList(growable: false);
  }

  @override
  Future<Leaderboard> getLeaderboard() async {
    final json = await _client.getObject(ApiEndpoints.leaderboard);
    return LeaderboardDto.fromJson(json).toEntity();
  }

  @override
  Future<StudyGroup?> getStudyGroup() async {
    final json = await _client.getObject(ApiEndpoints.studyGroup);
    // Chưa vào nhóm nào thì backend trả `{"group": null}` — không phải lỗi.
    final group = json.isEmpty ? null : json['group'];
    if (group is! JsonMap) return null;
    return StudyGroupDto.fromJson(group).toEntity();
  }

  @override
  Future<CommunityPost> setLiked(String postId, {required bool isLiked}) {
    // Thích là POST, bỏ thích là DELETE trên cùng một tài nguyên con.
    return _toggle(ApiEndpoints.postLike(postId), isOn: isLiked);
  }

  @override
  Future<CommunityPost> setBookmarked(
    String postId, {
    required bool isBookmarked,
  }) {
    return _toggle(ApiEndpoints.postBookmark(postId), isOn: isBookmarked);
  }

  Future<CommunityPost> _toggle(String path, {required bool isOn}) async {
    final json = isOn ? await _client.post(path) : await _client.delete(path);
    return CommunityPostDto.fromJson(json).toEntity();
  }

  @override
  Future<void> createPost({
    required SharedWord word,
    required String detectedLabel,
  }) async {
    await _client.post(
      ApiEndpoints.posts,
      body: {
        'detected_label': detectedLabel,
        'shared_word': {
          'english': word.english,
          'vietnamese': word.vietnamese,
          'phonetic': word.phonetic,
        },
      },
    );
  }

  // --- Nhom hoc tap & chat ---------------------------------------------
  //
  // Backend REST (docs/API_SPEC.md) chua bao gio co cac endpoint nay: nhom va
  // chat duoc lam sau khi du an da chuyen sang Firebase. Bao loi ro rang thay
  // vi tra du lieu rong, de khong ai tuong la da chay duoc.

  static const _notInRestApi = UnknownFailure(
    'Tinh nang nay chi co ban Firebase, backend REST chua ho tro.',
  );

  @override
  Future<List<StudyGroupSummary>> getJoinableGroups() async =>
      throw _notInRestApi;

  @override
  Future<void> createGroup(String name) async => throw _notInRestApi;

  @override
  Future<void> joinGroup(String groupId) async => throw _notInRestApi;

  @override
  Future<void> leaveGroup() async => throw _notInRestApi;

  @override
  Stream<List<ChatMessage>> watchGroupMessages(String groupId) =>
      Stream.error(_notInRestApi);

  @override
  Future<void> sendGroupMessage(
    String groupId, {
    String? text,
    String? stickerAsset,
  }) async => throw _notInRestApi;

  @override
  Stream<List<ChatMessage>> watchPostComments(String postId) =>
      Stream.error(_notInRestApi);

  @override
  Future<void> sendPostComment(
    String postId, {
    String? text,
    String? stickerAsset,
  }) async => throw _notInRestApi;
}
