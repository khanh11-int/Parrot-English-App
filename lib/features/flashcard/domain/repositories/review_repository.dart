import '../entities/review_deck.dart';

/// Nguồn dữ liệu các bộ từ cần ôn.
abstract interface class ReviewRepository {
  /// Danh sách bộ từ kèm số từ đến hạn ôn. Ném `Failure` nếu thất bại.
  Future<List<ReviewDeck>> getDecks();
}
