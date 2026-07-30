import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/review_deck.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_dtos.dart';

/// Lấy danh sách bộ từ cần ôn từ REST API.
class ReviewRemoteRepository implements ReviewRepository {
  const ReviewRemoteRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ReviewDeck>> getDecks() async {
    final items = await _client.getList(ApiEndpoints.decks);
    return items
        .map((json) => ReviewDeckDto.fromJson(json).toEntity())
        .toList(growable: false);
  }
}
