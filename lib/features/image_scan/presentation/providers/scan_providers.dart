import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../community/domain/entities/community_entities.dart';
import '../../../community/presentation/providers/community_providers.dart';
import '../../../quiz/domain/entities/vocabulary_topic.dart';
import '../../../quiz/presentation/providers/learn_providers.dart';
import '../../../vocabulary/domain/entities/saved_word.dart';
import '../../../vocabulary/presentation/providers/vocabulary_providers.dart';
import '../../data/repositories/image_scan_mock_repository.dart';
import '../../domain/entities/recognized_word.dart';
import '../../domain/repositories/image_scan_repository.dart';

/// Nhận diện vật thể trong ảnh.
///
/// ⚠️ **Đây là repository duy nhất còn dùng dữ liệu giả**, và không phải vì
/// chưa làm: nhận diện ảnh cần một dịch vụ AI, không phải dữ liệu trong
/// Firestore. Hai cách để làm thật:
///
/// - **Cloud Functions** gọi Vision AI (key nằm ở server) — cần gói Blaze.
/// - **ML Kit trên máy** (`google_mlkit_image_labeling`) — miễn phí, không cần
///   server, nhưng chỉ chạy trên Android/iOS, không có bản web.
final imageScanRepositoryProvider = Provider<ImageScanRepository>((ref) {
  return const ImageScanMockRepository();
});

/// Danh sách chủ đề để gán cho từ vựng.
///
/// Dùng chung nguồn với trang chọn chủ đề (Firestore `topics`), nên chủ đề gán
/// ở đây chắc chắn khớp id với chủ đề trong danh mục.
final scanTopicsProvider = FutureProvider<List<VocabularyTopic>>((ref) {
  return ref.watch(topicRepositoryProvider).getTopics();
});

/// Trạng thái của luồng nhận diện ảnh.
class ScanState {
  const ScanState({
    this.isProcessing = false,
    this.errorMessage,
    this.imagePath,
    this.words = const [],
    this.selectedWordIds = const {},
    this.areBoxesVisible = true,
    this.highlightedWordId,
  });

  final bool isProcessing;
  final String? errorMessage;
  final String? imagePath;

  /// Danh sách từ đang chỉnh sửa (có thể đã gán chủ đề).
  final List<RecognizedWord> words;

  /// Id các từ được tick để lưu.
  final Set<String> selectedWordIds;
  final bool areBoxesVisible;

  /// Từ đang được làm nổi do người dùng bấm vào khung trên ảnh.
  final String? highlightedWordId;

  bool get hasResult => words.isNotEmpty;

  List<RecognizedWord> get selectedWords =>
      words.where((w) => selectedWordIds.contains(w.id)).toList();

  ScanState copyWith({
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    String? imagePath,
    List<RecognizedWord>? words,
    Set<String>? selectedWordIds,
    bool? areBoxesVisible,
    String? highlightedWordId,
    bool clearHighlight = false,
  }) {
    return ScanState(
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      imagePath: imagePath ?? this.imagePath,
      words: words ?? this.words,
      selectedWordIds: selectedWordIds ?? this.selectedWordIds,
      areBoxesVisible: areBoxesVisible ?? this.areBoxesVisible,
      highlightedWordId: clearHighlight
          ? null
          : (highlightedWordId ?? this.highlightedWordId),
    );
  }
}

/// Điều khiển luồng: chọn ảnh → nhận diện → chỉnh sửa danh sách từ → lưu.
class ScanController extends Notifier<ScanState> {
  /// Đếm số lần gọi nhận diện. Kết quả của lần gọi cũ (hoặc lần đã bị huỷ) sẽ
  /// bị bỏ qua, tránh chuyện người dùng huỷ rồi kết quả vẫn nhảy vào.
  int _requestId = 0;

  @override
  ScanState build() => const ScanState();

  /// Gọi AI nhận diện ảnh. Trả về `true` nếu có kết quả dùng được.
  Future<bool> recognize({String? imagePath}) async {
    final requestId = ++_requestId;
    state = state.copyWith(
      isProcessing: true,
      imagePath: imagePath,
      clearError: true,
    );

    try {
      final result = await ref
          .read(imageScanRepositoryProvider)
          .recognize(imagePath: imagePath);

      if (requestId != _requestId) return false;

      state = state.copyWith(
        isProcessing: false,
        imagePath: result.imagePath,
        words: result.words,
        // Mặc định chọn hết: phần lớn trường hợp người dùng muốn lưu tất cả,
        // bỏ tick vài từ nhanh hơn là tick từng từ một.
        selectedWordIds: result.words.map((w) => w.id).toSet(),
        areBoxesVisible: true,
        clearHighlight: true,
      );
      return true;
    } on Failure catch (failure) {
      if (requestId != _requestId) return false;
      // Dùng thẳng thông điệp của `Failure`: nó đã là tiếng Việt và đúng nguyên
      // nhân (mất mạng / quá tải / server lỗi), không phải chuỗi exception thô.
      state = state.copyWith(
        isProcessing: false,
        errorMessage: failure.message,
      );
      return false;
    }
  }

  /// Lưu các từ đang chọn vào bộ từ cá nhân.
  ///
  /// [shouldPost] bật thì đăng thêm một bài lên Cộng đồng cho mỗi từ.
  /// Trả về `null` nếu thành công, hoặc thông điệp lỗi để trang hiển thị.
  Future<String?> saveSelectedWords({required bool shouldPost}) async {
    final words = state.selectedWords;
    if (words.isEmpty) return 'Chưa chọn từ nào để lưu.';

    try {
      await ref.read(savedWordRepositoryProvider).saveWords([
        for (final word in words)
          SavedWord(
            // Id sinh từ chữ tiếng Anh nên chụp trùng một vật sẽ ghi đè chứ
            // không tạo bản trùng trong bộ từ.
            id: SavedWord.idFrom(word.english),
            english: word.english,
            vietnamese: word.vietnamese,
            phonetic: word.phonetic,
            topicId: word.topicId,
          ),
      ]);

      if (shouldPost) {
        final community = ref.read(communityRepositoryProvider);
        for (final word in words) {
          await community.createPost(
            word: SharedWord(
              english: word.english,
              vietnamese: word.vietnamese,
              phonetic: word.phonetic,
            ),
            detectedLabel: word.overlayLabel,
          );
        }
        // Bài mới vừa xuất hiện, buộc dòng thời gian tải lại.
        ref.invalidate(feedProvider);
      }

      return null;
    } on Failure catch (failure) {
      return failure.message;
    }
  }

  /// Huỷ lần nhận diện đang chạy.
  void cancel() {
    _requestId++;
    state = state.copyWith(isProcessing: false, clearError: true);
  }

  void toggleWordSelection(String wordId) {
    final selected = Set<String>.from(state.selectedWordIds);
    if (!selected.remove(wordId)) selected.add(wordId);
    state = state.copyWith(selectedWordIds: selected);
  }

  void setTopic(String wordId, VocabularyTopic topic) {
    state = state.copyWith(
      words: [
        for (final word in state.words)
          if (word.id == wordId)
            word.copyWith(topicId: topic.id, topicName: topic.name)
          else
            word,
      ],
    );
  }

  /// Gán một chủ đề cho **mọi từ đang được chọn**.
  void setTopicForSelected(VocabularyTopic topic) {
    state = state.copyWith(
      words: [
        for (final word in state.words)
          if (state.selectedWordIds.contains(word.id))
            word.copyWith(topicId: topic.id, topicName: topic.name)
          else
            word,
      ],
    );
  }

  void toggleBoxesVisibility() {
    state = state.copyWith(areBoxesVisible: !state.areBoxesVisible);
  }

  /// Bấm khung trên ảnh → làm nổi thẻ từ tương ứng. Bấm lại thì bỏ nổi.
  void highlightWord(String? wordId) {
    if (wordId == null || wordId == state.highlightedWordId) {
      state = state.copyWith(clearHighlight: true);
    } else {
      state = state.copyWith(highlightedWordId: wordId);
    }
  }

  void reset() {
    _requestId++;
    state = const ScanState();
  }
}

final scanControllerProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);
