import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
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
