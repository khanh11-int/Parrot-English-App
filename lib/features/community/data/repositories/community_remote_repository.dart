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
}
