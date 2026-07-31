import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/review_deck.dart';

/// DTO của một phần tử trong `GET /me/decks`. Xem `docs/API_SPEC.md`.
class ReviewDeckDto {
  const ReviewDeckDto({
    required this.topicId,
    required this.topic,
    required this.totalCount,
    required this.learnedCount,
    required this.masteredCount,
    required this.dueCount,
  });

  final String topicId;
  final String topic;
  final int totalCount;
  final int learnedCount;
  final int masteredCount;
  final int dueCount;

  factory ReviewDeckDto.fromJson(JsonMap json) {
    return ReviewDeckDto(
      topicId: json.readString('topic_id'),
      topic: json.readString('topic'),
      totalCount: json.readIntOr('total_count', 0),
      learnedCount: json.readIntOr('learned_count', 0),
      masteredCount: json.readIntOr('mastered_count', 0),
      dueCount: json.readIntOr('due_count', 0),
    );
  }

  ReviewDeck toEntity() => ReviewDeck(
    topicId: topicId,
    topic: topic,
    totalCount: totalCount,
    learnedCount: learnedCount,
    masteredCount: masteredCount,
    dueCount: dueCount,
  );
}
