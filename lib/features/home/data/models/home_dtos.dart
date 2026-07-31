import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_reader.dart';
import '../../domain/entities/home_summary.dart';

/// DTO của `GET /me/home`. Xem `docs/API_SPEC.md`.
///
/// DTO tách khỏi entity: backend đổi tên field thì chỉ sửa `fromJson` ở đây,
/// entity và UI không đổi.
class HomeSummaryDto {
  const HomeSummaryDto({
    required this.userName,
    required this.streakDays,
    required this.gemCount,
    required this.seedCount,
    required this.learnedWordCount,
    required this.totalWordCount,
    required this.dailyQuests,
  });

  final String userName;
  final int streakDays;
  final int gemCount;
  final int seedCount;
  final int learnedWordCount;
  final int totalWordCount;
  final QuestGroupDto dailyQuests;

  factory HomeSummaryDto.fromJson(JsonMap json) {
    return HomeSummaryDto(
      userName: json.readStringOrNull('user_name') ?? 'bạn',
      streakDays: json.readIntOr('streak_days', 0),
      gemCount: json.readIntOr('gem_count', 0),
      seedCount: json.readIntOr('seed_count', 0),
      learnedWordCount: json.readIntOr('learned_word_count', 0),
      totalWordCount: json.readIntOr('total_word_count', 0),
      dailyQuests: QuestGroupDto.fromJson(json.readObject('daily_quests')),
    );
  }

  HomeSummary toEntity() {
    return HomeSummary(
      userName: userName,
      streakDays: streakDays,
      gemCount: gemCount,
      seedCount: seedCount,
      learnedWordCount: learnedWordCount,
      totalWordCount: totalWordCount,
      dailyQuests: dailyQuests.toEntity(),
    );
  }
}

class QuestGroupDto {
  const QuestGroupDto({required this.title, required this.quests});

  final String title;
  final List<QuestDto> quests;

  factory QuestGroupDto.fromJson(JsonMap json) {
    return QuestGroupDto(
      title: json.readString('title'),
      quests: json
          .readObjectList('quests')
          .map(QuestDto.fromJson)
          .toList(growable: false),
    );
  }

  QuestGroup toEntity() => QuestGroup(
    title: title,
    quests: quests.map((quest) => quest.toEntity()).toList(growable: false),
  );
}

class QuestDto {
  const QuestDto({
    required this.title,
    required this.completed,
    required this.target,
  });

  final String title;
  final int completed;
  final int target;

  factory QuestDto.fromJson(JsonMap json) {
    return QuestDto(
      title: json.readString('title'),
      completed: json.readIntOr('completed', 0),
      target: json.readIntOr('target', 0),
    );
  }

  Quest toEntity() => Quest(title: title, completed: completed, target: target);
}
