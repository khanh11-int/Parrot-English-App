import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/constants/app_rewards.dart';
import 'package:parrot/features/profile/data/models/user_document.dart';

void main() {
  group('UserDocument.dateKey', () {
    test('đệm 0 cho tháng và ngày một chữ số', () {
      expect(UserDocument.dateKey(DateTime(2026, 7, 5)), '2026-07-05');
      expect(UserDocument.dateKey(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });

  group('UserDocument.nextStreak', () {
    final now = DateTime(2026, 7, 31, 20);
    final today = UserDocument.dateKey(now);
    final yesterday = UserDocument.dateKey(
      now.subtract(const Duration(days: 1)),
    );

    int streakFor(Map<String, dynamic> data) =>
        UserDocument.nextStreak(data, now: now);

    test('người mới chưa từng học thì bắt đầu từ 1', () {
      expect(streakFor(const {}), 1);
    });

    test('đã học hôm nay thì giữ nguyên, không cộng theo từng câu', () {
      expect(streakFor({'lastActiveDate': today, 'streakDays': 5}), 5);
    });

    test('lần cuối là hôm qua thì cộng 1', () {
      expect(streakFor({'lastActiveDate': yesterday, 'streakDays': 5}), 6);
    });

    test('nghỉ từ 2 ngày trở lên thì chuỗi đứt, về 1', () {
      final twoDaysAgo = UserDocument.dateKey(
        now.subtract(const Duration(days: 2)),
      );
      expect(streakFor({'lastActiveDate': twoDaysAgo, 'streakDays': 30}), 1);
    });

    test('hôm nay nhưng streak đang 0 thì thành 1', () {
      // Xảy ra khi hồ sơ cũ có `lastActiveDate` mà thiếu `streakDays`.
      expect(streakFor({'lastActiveDate': today}), 1);
    });

    test('bỏ qua giá trị sai kiểu thay vì làm sập app', () {
      expect(streakFor({'lastActiveDate': 123, 'streakDays': 'nhiều'}), 1);
    });

    test('nhận cả số thực từ Firestore', () {
      expect(streakFor({'lastActiveDate': yesterday, 'streakDays': 4.0}), 5);
    });
  });

  group('Hằng số thưởng', () {
    test('mỗi câu đúng được 10 XP và 2 hạt', () {
      expect(AppRewards.experiencePerCorrectAnswer, 10);
      expect(AppRewards.seedsPerCorrectAnswer, 2);
    });
  });

  group('Mốc ôn tập SRS', () {
    test('từ vừa học lần đầu đến hạn ngay trong ngày', () {
      // Đây là điểm mấu chốt: nếu mốc đầu là 1 ngày thì học xong hôm nay phải
      // đợi tới mai mới ôn được, tab Ôn tập sẽ trống trơn.
      expect(
        AppRewards.nextIntervalDays(
          currentDays: 0,
          isCorrect: true,
          isFirstTime: true,
        ),
        0,
      );
    });

    test('trả lời đúng thì nhảy mốc tiếp theo', () {
      expect(
        AppRewards.nextIntervalDays(
          currentDays: 0,
          isCorrect: true,
          isFirstTime: false,
        ),
        1,
      );
      expect(
        AppRewards.nextIntervalDays(
          currentDays: 7,
          isCorrect: true,
          isFirstTime: false,
        ),
        21,
      );
    });

    test('mốc cuối thì giữ nguyên, không vượt ra ngoài danh sách', () {
      expect(
        AppRewards.nextIntervalDays(
          currentDays: 60,
          isCorrect: true,
          isFirstTime: false,
        ),
        60,
      );
    });

    test('trả lời sai thì về mốc đầu để gặp lại ngay', () {
      expect(
        AppRewards.nextIntervalDays(
          currentDays: 21,
          isCorrect: false,
          isFirstTime: false,
        ),
        0,
      );
    });

    test('mốc lạ (dữ liệu cũ) thì về mốc đầu thay vì làm sập', () {
      expect(
        AppRewards.nextIntervalDays(
          currentDays: 999,
          isCorrect: true,
          isFirstTime: false,
        ),
        0,
      );
    });
  });
}
