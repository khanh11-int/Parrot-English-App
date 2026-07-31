import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/constants/app_labels.dart';
import 'package:parrot/core/error/failure.dart';
import 'package:parrot/core/network/json_reader.dart';
import 'package:parrot/features/community/data/models/community_dtos.dart';
import 'package:parrot/features/home/data/models/home_dtos.dart';
import 'package:parrot/features/quiz/data/models/learn_dtos.dart';
import 'package:parrot/features/shop/data/models/shop_dtos.dart';

void main() {
  group('JsonReader', () {
    test('báo rõ tên field khi sai kiểu', () {
      expect(
        () => <String, dynamic>{'name': 42}.readString('name'),
        throwsA(
          isA<ParsingFailure>().having(
            (f) => f.message,
            'message',
            contains('"name"'),
          ),
        ),
      );
    });

    test('nhận số thực cho field số nguyên vì JSON không phân biệt', () {
      expect(<String, dynamic>{'count': 4.0}.readInt('count'), 4);
    });

    test('field thiếu thì dùng giá trị mặc định', () {
      expect(<String, dynamic>{}.readIntOr('count', 7), 7);
    });
  });

  group('HomeSummaryDto', () {
    test('parse đủ và đổi sang entity', () {
      final dto = HomeSummaryDto.fromJson({
        'streak_days': 3,
        'gem_count': 2,
        'seed_count': 15,
        'learned_word_count': 16,
        'total_word_count': 56,
        'daily_quests': {
          'title': 'Hằng ngày',
          'quests': [
            {'title': 'Lưu 5 từ', 'completed': 3, 'target': 5},
          ],
        },
      });

      final entity = dto.toEntity();
      expect(entity.streakDays, 3);
      expect(entity.curriculumPercent, 29);
      expect(entity.dailyQuests.quests.single.percent, 60);
    });
  });

  group('ExerciseDto', () {
    test('parse được cả hai dạng bài tập', () {
      final session = LearnSessionDto.fromJson({
        'id': 'sess_1',
        'title': 'Học từ mới',
        'exercises': [
          {
            'type': 'match_pairs',
            'pairs': [
              {'id': 'a', 'english': 'Cough', 'vietnamese': 'Ho'},
            ],
          },
          {
            'type': 'multiple_choice',
            'word': {'id': 'b', 'english': 'Diet', 'vietnamese': 'Ăn uống'},
            'options': ['Ăn uống', 'Ông'],
            'correct_option': 'Ăn uống',
          },
        ],
      }).toEntity();

      expect(session.id, 'sess_1');
      expect(session.exercises, hasLength(2));
    });

    test('dạng bài lạ báo lỗi rõ ràng thay vì bỏ qua vòng học', () {
      expect(
        () => ExerciseDto.fromJson({'type': 'listening'}),
        throwsA(
          isA<ParsingFailure>().having(
            (f) => f.message,
            'message',
            contains('listening'),
          ),
        ),
      );
    });
  });

  group('LeaderboardDto', () {
    test('map khoá hạng của backend sang enum tầng rừng', () {
      expect(LeaderboardDto.parseRank('lower_canopy'), ForestRank.lowerCanopy);
      expect(LeaderboardDto.parseRank('emergent'), ForestRank.emergent);
    });

    test('khoá lạ lùi về hạng thấp nhất, không làm sập bảng xếp hạng', () {
      expect(LeaderboardDto.parseRank('penthouse'), ForestRank.forestFloor);
    });
  });

  group('ShopItemDto', () {
    test('loại tiền lạ được coi là hạt', () {
      expect(ShopItemDto.parseCurrency('gem').name, 'gem');
      expect(ShopItemDto.parseCurrency('bitcoin').name, 'seed');
    });

    test('parse ví và vật phẩm', () {
      final data = ShopDataDto.fromJson({
        'wallet': {'seeds': 150, 'gems': 2},
        'items': [
          {
            'id': 'boost-fruit',
            'name': 'Quả Tăng Tốc',
            'price': 150,
            'currency': 'seed',
            'owned_count': 1,
          },
        ],
      }).toEntity();

      expect(data.wallet.seeds, 150);
      expect(data.ownedItems, hasLength(1));
      expect(data.wallet.canAfford(data.items.single), isTrue);
    });
  });

  group('Failure', () {
    test('lỗi không sửa được bằng thử lại thì không cho thử lại', () {
      expect(const UnauthorizedFailure().isRetryable, isFalse);
      expect(const ValidationFailure().isRetryable, isFalse);
      expect(const ParsingFailure().isRetryable, isFalse);
    });

    test('lỗi tạm thời thì cho thử lại', () {
      expect(const NetworkFailure().isRetryable, isTrue);
      expect(const TimeoutFailure().isRetryable, isTrue);
      expect(const RateLimitFailure().isRetryable, isTrue);
      expect(const ServerFailure().isRetryable, isTrue);
    });
  });
}
