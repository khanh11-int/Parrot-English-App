import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/learn_question.dart';
import '../../domain/repositories/learn_repository.dart';
import '../models/learn_dtos.dart';

/// Nội dung phiên học lấy từ REST API.
class LearnRemoteRepository implements LearnRepository {
  const LearnRemoteRepository(this._client);

  final ApiClient _client;

  @override
  Future<LearnSession> getLearnSession({String? topicId}) => _fetchSession(
    ApiEndpoints.learnSession,
    query: topicId == null ? null : {'topic_id': topicId},
  );

  @override
  Future<LearnSession> getReviewSession({String? topicId}) => _fetchSession(
    ApiEndpoints.reviewSession,
    query: topicId == null ? null : {'topic': topicId},
  );

  @override
  Future<void> submitResult(String sessionId, SessionResult result) async {
    await _client.post(
      ApiEndpoints.sessionResult(sessionId),
      body: result.toJson(),
    );
  }

  Future<LearnSession> _fetchSession(String path, {JsonMap? query}) async {
    final json = await _client.getObject(path, queryParameters: query);
    return LearnSessionDto.fromJson(json).toEntity();
  }
}
