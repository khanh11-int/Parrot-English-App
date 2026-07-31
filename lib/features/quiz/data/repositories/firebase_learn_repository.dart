import '../../../../core/error/failure.dart';
import '../../../vocabulary/domain/entities/topic_word.dart';
import '../../../vocabulary/domain/repositories/vocabulary_repository.dart';
import '../../domain/entities/learn_question.dart';
import '../../domain/repositories/learn_repository.dart';

/// Sinh phiên học từ **giáo trình của chủ đề** trên Firestore.
///
/// Học từ mới = lấy các từ trong chủ đề mà người dùng **chưa từng học**.
/// Ôn tập = lấy các từ đã học và đã đến hạn theo SRS.
class FirebaseLearnRepository implements LearnRepository {
  const FirebaseLearnRepository(this._vocabularyRepository);

  final VocabularyRepository _vocabularyRepository;

  /// Số từ dạy trong một phiên. Ít thôi để người học không bị quá tải.
  static const wordsPerSession = 4;

  /// Số đáp án của một câu trắc nghiệm.
  static const _optionCount = 4;

  @override
  Future<LearnSession> getLearnSession({String? topicId}) async {
    if (topicId == null) {
      throw const ValidationFailure('Hãy chọn một chủ đề để bắt đầu học.');
    }

    // Khoi tao truoc roi await tung cai: van chay song song vi future trong
    // Dart la eager. Khong dung `(f1, f2).wait` — no goi loi vao
    // ParallelWaitError nen `on FirebaseException` ben duoi se truot.
    final wordsFuture = _vocabularyRepository.getTopicWords(topicId);
    final progressFuture = _vocabularyRepository.getProgress(topicId: topicId);
    final words = await wordsFuture;
    final progress = await progressFuture;

    if (words.isEmpty) {
      throw const NotFoundFailure(
        'Chủ đề này chưa có từ vựng nào. Liên hệ quản trị viên để bổ sung.',
      );
    }

    final learnedIds = progress.map((item) => item.wordId).toSet();
    final unlearned = words
        .where((word) => !learnedIds.contains(word.id))
        .toList();

    if (unlearned.isEmpty) {
      throw const ValidationFailure(
        'Bạn đã học hết từ của chủ đề này rồi. '
        'Sang tab Ôn tập để nhớ lâu hơn nhé!',
      );
    }

    return _buildSession(
      title: 'Học từ mới',
      words: unlearned.take(wordsPerSession).toList(),
      // Đáp án nhiễu lấy từ cả chủ đề, kể cả từ đã học — câu hỏi khó hơn và
      // cũng là dịp nhắc lại từ cũ.
      distractorPool: words,
    );
  }

  @override
  Future<LearnSession> getReviewSession() async {
    final due = await _vocabularyRepository.getDueProgress();

    // Hết từ đến hạn thì ôn lại từ đã học, **không** chặn người dùng lại.
    //
    // Lịch SRS là gợi ý "nên ôn lúc nào cho nhớ lâu", không phải cái khoá. Nếu
    // chặn thì học xong một chủ đề là tab Ôn tập đứng im tới hôm sau, người học
    // muốn luyện thêm cũng không được.
    // Từ đến hạn đã sắp theo `dueAt` nên quá hạn lâu nhất lên trước. Còn khi ôn
    // lại tự do thì xáo, không thì lần nào cũng đúng bốn từ đầu bảng.
    final List<WordProgress> source;
    if (due.isNotEmpty) {
      source = due;
    } else {
      source = [...await _vocabularyRepository.getProgress()]..shuffle();
    }

    if (source.isEmpty) {
      throw const ValidationFailure(
        'Bạn chưa học từ nào cả. Sang tab Học từ mới trước nhé!',
      );
    }

    final words = source
        .map(
          (item) => TopicWord(
            id: item.wordId,
            topicId: item.topicId,
            english: item.english,
            vietnamese: item.vietnamese,
            phonetic: item.phonetic,
          ),
        )
        .toList();

    return _buildSession(
      title: 'Ôn tập',
      words: words.take(wordsPerSession).toList(),
      distractorPool: words,
    );
  }

  @override
  Future<void> submitResult(String sessionId, SessionResult result) async {
    // Tiến độ từng từ đã được `SessionController` ghi ngay sau mỗi vòng qua
    // `VocabularyRepository.recordAnswer`, nên ở đây không còn gì phải gửi.
  }

  LearnSession _buildSession({
    required String title,
    required List<TopicWord> words,
    required List<TopicWord> distractorPool,
  }) {
    final pairs = words
        .map(
          (word) => WordPair(
            id: word.id,
            english: word.english,
            vietnamese: word.vietnamese,
          ),
        )
        .toList();

    return LearnSession(
      id: 'local-${words.first.topicId}-${pairs.length}',
      title: title,
      exercises: [
        // Vòng đầu nối cặp để làm quen mặt chữ; chỉ tạo khi có từ 2 cặp trở lên.
        if (pairs.length >= 2) MatchPairsExerciseData(pairs: pairs),
        // Rồi trắc nghiệm từng từ để kiểm lại.
        for (final pair in pairs)
          MultipleChoiceExerciseData(
            word: pair,
            options: _optionsFor(pair, distractorPool),
            correctOption: pair.vietnamese,
          ),
      ],
    );
  }

  /// Bốn đáp án: nghĩa đúng cộng ba nghĩa lấy từ các từ khác trong chủ đề.
  ///
  /// Lấy nhiễu từ **cùng chủ đề** để câu hỏi thật sự phải phân biệt nghĩa, chứ
  /// không loại trừ được bằng mắt như khi nhiễu là từ chủ đề khác hẳn.
  List<String> _optionsFor(WordPair correct, List<TopicWord> pool) {
    final distractors = pool
        .where((word) => word.id != correct.id)
        .map((word) => word.vietnamese)
        .where((meaning) => meaning.isNotEmpty && meaning != correct.vietnamese)
        .toSet()
        .take(_optionCount - 1)
        .toList();

    final options = [correct.vietnamese, ...distractors];
    // Xáo theo id của từ: thứ tự cố định trong một phiên (không nhảy khi
    // rebuild) nhưng khác nhau giữa các câu.
    options.sort(
      (a, b) => (a.hashCode ^ correct.id.hashCode).compareTo(
        b.hashCode ^ correct.id.hashCode,
      ),
    );
    return options;
  }
}
