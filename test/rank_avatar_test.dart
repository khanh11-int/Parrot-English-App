import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parrot/core/constants/app_assets.dart';
import 'package:parrot/core/constants/app_labels.dart';
import 'package:parrot/shared/widgets/rank_avatar.dart';

/// Đường dẫn asset của ảnh đầu tiên trong cây widget.
String assetOf(WidgetTester tester) {
  final image = tester.widget<Image>(find.byType(Image));
  return (image.image as AssetImage).assetName;
}

Future<void> pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Center(child: child)));

void main() {
  group('AppAssets.rankBadge', () {
    test('mỗi hạng một huy hiệu, đánh số từ 1', () {
      expect(
        AppAssets.rankBadge(ForestRank.forestFloor.index),
        'assets/images/ranks/level-1.png',
      );
      expect(
        AppAssets.rankBadge(ForestRank.emergent.index),
        'assets/images/ranks/level-6.png',
      );
    });

    test(
      'chỉ số ngoài khoảng bị kẹp lại, không sinh đường dẫn không tồn tại',
      () {
        expect(AppAssets.rankBadge(-3), 'assets/images/ranks/level-1.png');
        expect(AppAssets.rankBadge(99), 'assets/images/ranks/level-6.png');
      },
    );

    test('có đúng 6 huy hiệu, khớp số hạng của thang rừng', () {
      expect(AppAssets.allRankBadges, hasLength(ForestRank.values.length));
    });
  });

  group('RankAvatar', () {
    testWidgets('chưa có ảnh tự đặt thì dùng huy hiệu hạng', (tester) async {
      // Đây là trường hợp của **mọi tài khoản mới**: `avatarUrl` trong Firestore
      // là chuỗi rỗng. Trước đây chuỗi rỗng đi thẳng vào `AppImage` nên hồ sơ
      // hiện một ô xám vỡ ảnh.
      await pump(
        tester,
        const RankAvatar(rank: ForestRank.midCanopy, size: 56),
      );

      expect(assetOf(tester), 'assets/images/ranks/level-4.png');
    });

    testWidgets('có ảnh tự đặt thì ưu tiên ảnh đó', (tester) async {
      await pump(
        tester,
        const RankAvatar(
          rank: ForestRank.forestFloor,
          size: 56,
          avatarAsset: AppAssets.stickerHello,
        ),
      );

      expect(assetOf(tester), AppAssets.stickerHello);
    });

    testWidgets('dựng từ XP thì suy ra đúng hạng', (tester) async {
      // 1290 XP: đã qua mốc 500 (Bụi Rậm), chưa tới 1500 (Tán Thấp).
      await pump(tester, RankAvatar.fromExperience(experience: 1290, size: 36));

      expect(assetOf(tester), 'assets/images/ranks/level-2.png');
    });

    testWidgets('lên hạng thì huy hiệu đổi theo', (tester) async {
      await pump(tester, RankAvatar.fromExperience(experience: 499, size: 36));
      expect(assetOf(tester), 'assets/images/ranks/level-1.png');

      // Thêm 1 XP là vượt mốc 500 → sang huy hiệu kế tiếp.
      await pump(tester, RankAvatar.fromExperience(experience: 500, size: 36));
      expect(assetOf(tester), 'assets/images/ranks/level-2.png');
    });
  });
}
