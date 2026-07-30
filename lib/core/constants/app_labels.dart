/// Bộ tên gọi theo chủ đề **rừng rậm**. Xem mục 2.6 của `UI_SPEC.md`.
///
/// Gom ở một chỗ để đổi tên hạng / vật phẩm không phải sửa rải rác trong UI,
/// và để sau này thêm đa ngôn ngữ chỉ cần thay lớp này.
abstract final class AppLabels {
  // --- Tiền tệ ----------------------------------------------------------
  static const seed = 'Hạt';
  static const gem = 'Ngọc';
  static const experience = 'Kinh nghiệm';

  // --- Điều hướng -------------------------------------------------------
  static const navHome = 'Trang chủ';
  static const navReview = 'Ôn tập';
  static const navCommunity = 'Cộng đồng';
  static const navProfile = 'Hồ sơ';

  // --- Hành động chung --------------------------------------------------
  static const retry = 'Thử lại';
  static const continueAction = 'Tiếp tục';
  static const check = 'Kiểm tra';
  static const finish = 'Hoàn thành';
  static const cancel = 'Huỷ';
  static const chooseTopic = 'chọn chủ đề';
  static const saveVocabulary = 'Lưu từ vựng';
  static const saveAndPost = 'Lưu và đăng tải';
}

/// Thang hạng cá nhân — 6 tầng rừng, vẹt leo dần lên cao.
enum ForestRank {
  forestFloor('Thảm Rừng', 0),
  undergrowth('Bụi Rậm', 500),
  lowerCanopy('Tán Thấp', 1500),
  midCanopy('Tán Giữa', 4000),
  upperCanopy('Tán Cao', 10000),
  emergent('Vượt Tán', 25000);

  const ForestRank(this.label, this.requiredExperience);

  final String label;
  final int requiredExperience;

  /// Hạng cao nhất mà [experience] đã đạt được.
  static ForestRank fromExperience(int experience) {
    var result = ForestRank.forestFloor;
    for (final rank in ForestRank.values) {
      if (experience >= rank.requiredExperience) result = rank;
    }
    return result;
  }

  /// Hạng kế tiếp, `null` nếu đã ở hạng cao nhất.
  ForestRank? get next {
    final nextIndex = index + 1;
    return nextIndex < ForestRank.values.length
        ? ForestRank.values[nextIndex]
        : null;
  }
}

/// Mốc của nhóm học tập — cây lớn dần từ chồi non thành đại thụ.
enum GroupMilestone {
  sprout('Chồi Non', 600),
  sturdyTree('Cây Vững', 16000),
  greatTree('Đại Thụ', 30000);

  const GroupMilestone(this.label, this.requiredExperience);

  final String label;
  final int requiredExperience;
}
