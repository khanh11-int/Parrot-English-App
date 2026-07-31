import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/constants/app_labels.dart';
import 'package:parrot/features/home/domain/entities/home_summary.dart';
import 'package:parrot/features/profile/domain/entities/user_profile.dart';
import 'package:parrot/features/shop/domain/entities/shop_item.dart';

void main() {
  group('Quest', () {
    test('tính đúng tỉ lệ hoàn thành', () {
      const quest = Quest(title: 'Học từ mới', completed: 9, target: 15);
      expect(quest.progress, closeTo(0.6, 0.001));
      expect(quest.percent, 60);
      expect(quest.isCompleted, isFalse);
    });

    test('mục tiêu bằng 0 không gây chia cho 0', () {
      const quest = Quest(title: 'Rỗng', completed: 0, target: 0);
      expect(quest.progress, 0);
    });

    test('kẹp tỉ lệ ở 1 khi làm vượt mục tiêu', () {
      const quest = Quest(title: 'Vượt', completed: 20, target: 15);
      expect(quest.progress, 1);
      expect(quest.isCompleted, isTrue);
    });
  });

  group('HomeSummary.curriculumProgress', () {
    HomeSummary summaryWith({required int learned, required int total}) =>
        HomeSummary(
          userName: 'bạn',
          streakDays: 0,
          gemCount: 0,
          seedCount: 0,
          learnedWordCount: learned,
          totalWordCount: total,
          dailyQuests: const QuestGroup(title: 'Hôm nay', quests: []),
        );

    test('tính đúng phần trăm giáo trình', () {
      final summary = summaryWith(learned: 16, total: 56);
      expect(summary.curriculumPercent, 29);
    });

    test('giáo trình rỗng không gây chia cho 0', () {
      expect(summaryWith(learned: 0, total: 0).curriculumProgress, 0);
    });
  });

  group('ForestRank', () {
    test('suy ra đúng hạng theo XP', () {
      expect(ForestRank.fromExperience(0), ForestRank.forestFloor);
      expect(ForestRank.fromExperience(499), ForestRank.forestFloor);
      expect(ForestRank.fromExperience(500), ForestRank.undergrowth);
      expect(ForestRank.fromExperience(568), ForestRank.undergrowth);
      expect(ForestRank.fromExperience(99999), ForestRank.emergent);
    });

    test('hạng cao nhất không có hạng kế tiếp', () {
      expect(ForestRank.emergent.next, isNull);
      expect(ForestRank.forestFloor.next, ForestRank.undergrowth);
    });
  });

  group('UserProfile', () {
    const profile = UserProfile(
      name: 'Công Tình',
      avatarAsset: 'a.png',
      experience: 568,
      streakDays: 1,
      groupName: 'neu',
    );

    test('hạng suy ra từ XP nên không lệch với dữ liệu', () {
      expect(profile.rank, ForestRank.undergrowth);
    });

    test('tiến độ lên hạng kế tiếp nằm trong 0..1', () {
      // 568 XP: đã qua mốc 500 (Bụi Rậm), đang tiến tới 1500 (Tán Thấp).
      expect(profile.progressToNextRank, closeTo(68 / 1000, 0.001));
    });
  });

  group('Wallet', () {
    const wallet = Wallet(seeds: 150, gems: 2);
    const cheapItem = ShopItem(
      id: 'a',
      name: 'Quả Tăng Tốc',
      description: '',
      iconAsset: 'a.png',
      price: 150,
      currency: ShopCurrency.seed,
    );
    const expensiveItem = ShopItem(
      id: 'b',
      name: 'Khiên Vỏ Cây',
      description: '',
      iconAsset: 'b.png',
      price: 200,
      currency: ShopCurrency.seed,
    );

    test('mua được khi đủ tiền, không mua được khi thiếu', () {
      expect(wallet.canAfford(cheapItem), isTrue);
      expect(wallet.canAfford(expensiveItem), isFalse);
    });

    test('trừ đúng loại tiền khi mua', () {
      final after = wallet.spend(cheapItem);
      expect(after.seeds, 0);
      expect(after.gems, 2, reason: 'mua bằng hạt thì ngọc phải không đổi');
    });
  });

  group('SessionResult qua QuestGroup', () {
    test('tiến độ nhóm nhiệm vụ là trung bình các nhiệm vụ con', () {
      const group = QuestGroup(
        title: 'Hằng ngày',
        quests: [
          Quest(title: 'a', completed: 1, target: 2),
          Quest(title: 'b', completed: 0, target: 2),
        ],
      );
      expect(group.progress, closeTo(0.25, 0.001));
      expect(group.percent, 25);
    });

    test('nhóm rỗng có tiến độ 0', () {
      const group = QuestGroup(title: 'Rỗng', quests: []);
      expect(group.progress, 0);
    });
  });
}
