import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bộ đếm tăng mỗi khi dữ liệu của người dùng vừa đổi trên Firestore
/// (XP, hạt, streak, tiến độ chủ đề, lịch ôn).
///
/// Mọi provider hiển thị các số đó chỉ cần `ref.watch` bộ đếm này là tự tải
/// lại. Nếu không có nó thì chỗ ghi dữ liệu (phiên học) phải tự biết và
/// `invalidate` từng provider ở trang chủ / hồ sơ / cửa hàng / ôn tập — tức
/// feature `quiz` phải import bốn feature khác, và thêm màn hình mới là lại
/// quên một chỗ.
class UserDataRevision extends Notifier<int> {
  @override
  int build() => 0;

  /// Gọi sau khi ghi xong dữ liệu người dùng.
  void bump() => state = state + 1;
}

final userDataRevisionProvider = NotifierProvider<UserDataRevision, int>(
  UserDataRevision.new,
);
