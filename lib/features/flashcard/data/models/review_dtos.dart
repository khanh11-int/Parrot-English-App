import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/review_deck.dart';

/// DTO của một phần tử trong `GET /me/decks`. Xem `API_SPEC.md`.
class ReviewDeckDto {
  const ReviewDeckDto({
    required this.topic,
    required this.totalCount,
    required this.masteredCount,
    required this.dueCount,
  });

  final String topic;
  final int totalCount;
  final int masteredCount;
  final int dueCount;

  factory ReviewDeckDto.fromJson(JsonMap json) {
    return ReviewDeckDto(
      topic: json.readString('topic'),
      totalCount: json.readIntOr('total_count', 0),
      masteredCount: json.readIntOr('mastered_count', 0),
      dueCount: json.readIntOr('due_count', 0),
    );
  }

  ReviewDeck toEntity() => ReviewDeck(
    topic: topic,
    totalCount: totalCount,
    masteredCount: masteredCount,
    dueCount: dueCount,
  );
}
