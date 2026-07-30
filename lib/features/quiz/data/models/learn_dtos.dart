import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/learn_question.dart';
import '../../domain/entities/vocabulary_topic.dart';

/// DTO của `GET /me/topics`. Xem `API_SPEC.md`.
class VocabularyTopicDto {
  const VocabularyTopicDto({
    required this.id,
    required this.name,
    required this.learnedCount,
    required this.totalCount,
    required this.iconUrl,
  });

  final String id;
  final String name;
  final int learnedCount;
  final int totalCount;
  final String iconUrl;

  factory VocabularyTopicDto.fromJson(JsonMap json) => VocabularyTopicDto(
    id: json.readString('id'),
    name: json.readString('name'),
    learnedCount: json.readIntOr('learned_count', 0),
    totalCount: json.readIntOr('total_count', 0),
    iconUrl: json.readStringOrNull('icon_url') ?? '',
  );

  VocabularyTopic toEntity() => VocabularyTopic(
    id: id,
    name: name,
    learnedCount: learnedCount,
    totalCount: totalCount,
    iconAsset: iconUrl,
  );
}

/// DTO của `GET /sessions/learn` và `GET /sessions/review`.
class LearnSessionDto {
  const LearnSessionDto({
    required this.id,
    required this.title,
    required this.exercises,
  });

  final String id;
  final String title;
  final List<ExerciseDto> exercises;

  factory LearnSessionDto.fromJson(JsonMap json) {
    return LearnSessionDto(
      id: json.readString('id'),
      title: json.readString('title'),
      exercises: json
          .readObjectList('exercises')
          .map(ExerciseDto.fromJson)
          .toList(growable: false),
    );
  }

  LearnSession toEntity() => LearnSession(
    id: id,
    title: title,
    exercises: exercises
        .map((exercise) => exercise.toEntity())
        .toList(growable: false),
  );
}

/// Một vòng bài tập. Field `type` quyết định các field còn lại có nghĩa gì.
class ExerciseDto {
  const ExerciseDto({
    required this.type,
    this.pairs = const [],
    this.word,
    this.options = const [],
    this.correctOption,
  });

  static const typeMatchPairs = 'match_pairs';
  static const typeMultipleChoice = 'multiple_choice';

  final String type;
  final List<WordPairDto> pairs;
  final WordPairDto? word;
  final List<String> options;
  final String? correctOption;

  factory ExerciseDto.fromJson(JsonMap json) {
    final type = json.readString('type');
    return switch (type) {
      typeMatchPairs => ExerciseDto(
        type: type,
        pairs: json
            .readObjectList('pairs')
            .map(WordPairDto.fromJson)
            .toList(growable: false),
      ),
      typeMultipleChoice => ExerciseDto(
        type: type,
        word: WordPairDto.fromJson(json.readObject('word')),
        options: json.readStringList('options'),
        correctOption: json.readString('correct_option'),
      ),
      // Backend thêm dạng bài mới mà app chưa hỗ trợ thì báo lỗi rõ ràng, không
      // im lặng bỏ qua vòng học.
      _ => throw ParsingFailure('Dạng bài tập không hỗ trợ: "$type".'),
    };
  }

  Exercise toEntity() {
    if (type == typeMatchPairs) {
      return MatchPairsExerciseData(
        pairs: pairs.map((pair) => pair.toEntity()).toList(growable: false),
      );
    }

    final currentWord = word;
    final answer = correctOption;
    if (currentWord == null || answer == null) {
      throw const ParsingFailure('Bài trắc nghiệm thiếu từ hoặc đáp án đúng.');
    }
    return MultipleChoiceExerciseData(
      word: currentWord.toEntity(),
      options: options,
      correctOption: answer,
    );
  }
}

class WordPairDto {
  const WordPairDto({
    required this.id,
    required this.english,
    required this.vietnamese,
  });

  final String id;
  final String english;
  final String vietnamese;

  factory WordPairDto.fromJson(JsonMap json) => WordPairDto(
    id: json.readString('id'),
    english: json.readString('english'),
    vietnamese: json.readString('vietnamese'),
  );

  WordPair toEntity() =>
      WordPair(id: id, english: english, vietnamese: vietnamese);
}

/// Body của `POST /sessions/{id}/result`.
extension SessionResultBody on SessionResult {
  JsonMap toJson() => {
    'learned_word_count': learnedWordCount,
    'correct_count': correctCount,
    'wrong_count': wrongCount,
  };
}
