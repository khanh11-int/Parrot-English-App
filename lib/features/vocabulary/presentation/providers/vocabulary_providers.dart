import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_saved_word_repository.dart';
import '../../data/repositories/firebase_vocabulary_repository.dart';
import '../../domain/repositories/vocabulary_repository.dart';

/// Bộ từ vựng của người dùng, lưu trong Firestore.
///
/// Test override provider này bằng bản giả.
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  return FirebaseVocabularyRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

/// Bộ từ người dùng lưu từ ảnh chụp — tách hẳn khỏi phần học.
final savedWordRepositoryProvider = Provider<SavedWordRepository>((ref) {
  return FirebaseSavedWordRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});
