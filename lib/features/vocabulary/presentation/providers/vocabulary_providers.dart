import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_saved_word_repository.dart';
import '../../data/repositories/firebase_vocabulary_repository.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/saved_word.dart';
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

/// Danh sách từ đã lưu từ ảnh, kèm thao tác xoá.
class SavedWordsController extends AsyncNotifier<List<SavedWord>> {
  @override
  Future<List<SavedWord>> build() {
    // Đổi người đăng nhập thì tải lại: đây là sổ tay riêng của từng người.
    ref.watch(currentUserProvider);
    return ref.read(savedWordRepositoryProvider).getSavedWords();
  }

  /// Xoá một từ. Trả `null` nếu thành công, hoặc thông điệp lỗi.
  Future<String?> remove(String wordId) async {
    final words = state.valueOrNull;
    if (words == null) return null;

    // Bỏ khỏi danh sách trước cho mượt, lỗi thì đặt lại — UI không được nói
    // dối rằng đã xoá khi server chưa xoá được.
    state = AsyncData(words.where((word) => word.id != wordId).toList());

    try {
      await ref.read(savedWordRepositoryProvider).removeWord(wordId);
      return null;
    } on Failure catch (failure) {
      state = AsyncData(words);
      return failure.message;
    }
  }
}

final savedWordsControllerProvider =
    AsyncNotifierProvider<SavedWordsController, List<SavedWord>>(
      SavedWordsController.new,
    );
