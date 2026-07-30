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
    required this.learnGoal,
    required this.reviewGoal,
    required this.monthlyQuest,
    required this.dailyQuests,
  });

  final String userName;
  final int streakDays;
  final int gemCount;
  final int seedCount;
  final DailyGoalDto learnGoal;
  final DailyGoalDto reviewGoal;
  final QuestGroupDto monthlyQuest;
  final QuestGroupDto dailyQuests;

  factory HomeSummaryDto.fromJson(JsonMap json) {
    return HomeSummaryDto(
      userName: json.readStringOrNull('user_name') ?? 'bạn',
      streakDays: json.readIntOr('streak_days', 0),
      gemCount: json.readIntOr('gem_count', 0),
      seedCount: json.readIntOr('seed_count', 0),
      learnGoal: DailyGoalDto.fromJson(json.readObject('learn_goal')),
      reviewGoal: DailyGoalDto.fromJson(json.readObject('review_goal')),
      monthlyQuest: QuestGroupDto.fromJson(json.readObject('monthly_quest')),
      dailyQuests: QuestGroupDto.fromJson(json.readObject('daily_quests')),
    );
  }

  HomeSummary toEntity() {
    return HomeSummary(
      userName: userName,
      streakDays: streakDays,
      gemCount: gemCount,
      seedCount: seedCount,
      learnGoal: learnGoal.toEntity(),
      reviewGoal: reviewGoal.toEntity(),
      monthlyQuest: monthlyQuest.toEntity(),
      dailyQuests: dailyQuests.toEntity(),
    );
  }
}

class DailyGoalDto {
  const DailyGoalDto({
    required this.title,
    required this.completed,
    required this.target,
  });

  final String title;
  final int completed;
  final int target;

  factory DailyGoalDto.fromJson(JsonMap json) {
    return DailyGoalDto(
      title: json.readString('title'),
      completed: json.readIntOr('completed', 0),
      target: json.readIntOr('target', 0),
    );
  }

  DailyGoal toEntity() =>
      DailyGoal(title: title, completed: completed, target: target);
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
