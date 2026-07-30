import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/constants/app_labels.dart';
import 'package:parrot/core/error/failure.dart';
import 'package:parrot/core/network/json_reader.dart';
import 'package:parrot/features/community/data/models/community_dtos.dart';
import 'package:parrot/features/home/data/models/home_dtos.dart';
import 'package:parrot/features/image_scan/data/models/scan_dtos.dart';
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
        'learn_goal': {'title': 'Học từ mới', 'completed': 9, 'target': 15},
        'review_goal': {'title': 'Ôn tập ngay', 'completed': 1, 'target': 30},
        'monthly_quest': {'title': 'Tháng Chín', 'quests': <dynamic>[]},
        'daily_quests': {
          'title': 'Hằng ngày',
          'quests': [
            {'title': 'Lưu 5 từ', 'completed': 3, 'target': 5},
          ],
        },
      });

      final entity = dto.toEntity();
      expect(entity.streakDays, 3);
      expect(entity.learnGoal.progress, closeTo(0.6, 0.001));
      expect(entity.dailyQuests.quests.single.percent, 60);
    });
  });

  group('ScanResultDto', () {
    test('lúc đang xử lý thì chưa có words', () {
      final dto = ScanResultDto.fromJson({
        'id': 'scan_1',
        'status': 'processing',
      });

      expect(dto.status, ScanStatus.processing);
      expect(dto.words, isEmpty);
    });

    test('trạng thái lạ được coi là chưa xong để client hỏi lại', () {
      final dto = ScanResultDto.fromJson({'id': 'scan_1', 'status': 'queued'});
      expect(dto.status, ScanStatus.processing);
    });

    test('giữ toạ độ khung theo tỉ lệ 0..1', () {
      final dto = ScanResultDto.fromJson({
        'id': 'scan_1',
        'status': 'completed',
        'words': [
          {
            'id': 'chair',
            'english': 'chair',
            'vietnamese': 'cái ghế',
            'phonetic': '/tʃeə(r)/',
            'confidence': 0.98,
            'bounding_box': {
              'left': 0.06,
              'top': 0.42,
              'width': 0.30,
              'height': 0.46,
            },
          },
        ],
      });

      final word = dto.toEntity(localImagePath: '/tmp/a.jpg').words.single;
      expect(word.overlayLabel, 'chair 0.98');
      expect(word.boundingBox.left, closeTo(0.06, 0.0001));

      // Đổi sang pixel theo kích thước hiển thị thật.
      final scaled = word.boundingBox.scaleTo(400, 300);
      expect(scaled.left, closeTo(24, 0.01));
    });

    test('ưu tiên ảnh local hơn ảnh trên server để hiện ngay', () {
      final dto = ScanResultDto.fromJson({
        'id': 'scan_1',
        'status': 'completed',
        'image_url': 'https://cdn/a.jpg',
        'words': <dynamic>[],
      });

      expect(
        dto.toEntity(localImagePath: '/tmp/a.jpg').imagePath,
        '/tmp/a.jpg',
      );
      expect(dto.toEntity().imagePath, 'https://cdn/a.jpg');
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

  group('CommunityPostDto', () {
    test('field thiếu dùng giá trị an toàn', () {
      final post = CommunityPostDto.fromJson({
        'id': 'p1',
        'author_name': 'Ai đó',
        'shared_word': {'english': 'person', 'vietnamese': 'người'},
      }).toEntity();

      expect(post.likeCount, 0);
      expect(post.isLiked, isFalse);
      expect(post.sharedWord.phonetic, '');
      expect(post.timeAgo, '');
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
