import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_labels.dart';
import '../../core/theme/app_colors.dart';
import 'app_image.dart';

/// Avatar tròn của một người học, **đổi theo hạng tầng rừng**.
///
/// Vẹt lớn dần theo hạng: nở từ trứng ở Thảm Rừng, tới Vượt Tán thì đội vương
/// miện. Người học nhìn avatar là biết mình đang ở đâu, không phải mở Hồ sơ ra
/// đọc chữ.
///
/// Hạng suy từ XP (`ForestRank.fromExperience`) nên không thể lệch với thanh
/// tiến độ hay nhãn hạng — cùng một nguồn số.
class RankAvatar extends StatelessWidget {
  const RankAvatar({
    super.key,
    required this.rank,
    required this.size,
    this.avatarAsset = '',
    this.backgroundColor = AppColors.bgBase,
  });

  /// Dựng avatar trực tiếp từ XP, cho chỗ chỉ có số XP trong tay.
  RankAvatar.fromExperience({
    Key? key,
    required int experience,
    required double size,
    String avatarAsset = '',
    Color backgroundColor = AppColors.bgBase,
  }) : this(
         key: key,
         rank: ForestRank.fromExperience(experience),
         size: size,
         avatarAsset: avatarAsset,
         backgroundColor: backgroundColor,
       );

  final ForestRank rank;

  /// Đường kính vòng tròn.
  final double size;

  /// Ảnh người dùng tự đặt. **Rỗng là chuyện bình thường** — tài khoản mới có
  /// `avatarUrl` rỗng — lúc đó dùng huy hiệu hạng. Trước đây chỗ này đưa thẳng
  /// chuỗi rỗng cho `AppImage` nên hồ sơ hiện một ô xám vỡ ảnh.
  final String avatarAsset;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: AppImage(
          source: avatarAsset.isNotEmpty
              ? avatarAsset
              : AppAssets.rankBadge(rank.index),
          width: size,
          height: size,
          // `cover` chứ không `contain`: huy hiệu hạng có nền bo góc riêng, để
          // `contain` thì thấy viền nền vuông lệch ra khỏi vòng tròn.
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
