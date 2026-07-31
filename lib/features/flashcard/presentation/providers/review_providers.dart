import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_data_revision.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_review_repository.dart';
import '../../domain/entities/review_deck.dart';
import '../../domain/repositories/review_repository.dart';

/// Danh sách bộ từ cần ôn, đọc từ Firestore.
///
/// Test override provider này bằng `ReviewMockRepository`.
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return FirebaseReviewRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

/// Danh sách bộ từ để vẽ tab Ôn tập.
final reviewDecksProvider = FutureProvider<List<ReviewDeck>>((ref) {
  ref.watch(currentUserProvider);
  // Vừa học xong là các từ đó đến hạn ôn ngay, danh sách phải hiện chúng luôn.
  ref.watch(userDataRevisionProvider);
  return ref.watch(reviewRepositoryProvider).getDecks();
});
