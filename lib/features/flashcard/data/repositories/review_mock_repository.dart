import '../../domain/entities/review_deck.dart';
import '../../domain/repositories/review_repository.dart';

/// Dữ liệu mock, dùng khi chưa khai báo `PARROT_API_BASE_URL`.
///
/// Giữ lại để người làm UI không bị chặn khi backend chưa xong, và để test
/// widget chạy được mà không cần server.
class ReviewMockRepository implements ReviewRepository {
  const ReviewMockRepository();

  static const _mockDelay = Duration(milliseconds: 400);

  @override
  Future<List<ReviewDeck>> getDecks() async {
    await Future<void>.delayed(_mockDelay);

    return const [
      ReviewDeck(
        topic: 'Đồ nội thất',
        totalCount: 24,
        learnedCount: 21,
        masteredCount: 15,
        dueCount: 6,
      ),
      ReviewDeck(
        topic: 'Sức khoẻ',
        totalCount: 18,
        learnedCount: 13,
        masteredCount: 4,
        dueCount: 9,
      ),
      ReviewDeck(
        topic: 'Gia đình',
        totalCount: 12,
        learnedCount: 12,
        masteredCount: 12,
        dueCount: 0,
      ),
      ReviewDeck(
        topic: 'Công nghệ',
        totalCount: 30,
        learnedCount: 23,
        masteredCount: 8,
        dueCount: 15,
      ),
    ];
  }
}
