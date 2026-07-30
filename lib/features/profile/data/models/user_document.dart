import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';

/// Ánh xạ document Firestore `users/{uid}`.
///
/// Tách khỏi entity giống các DTO khác: đổi tên field trên Firestore chỉ sửa ở
/// đây, UI không đổi.
class UserDocument {
  const UserDocument({
    required this.name,
    required this.avatarUrl,
    required this.experience,
    required this.streakDays,
    required this.seeds,
    required this.gems,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    this.groupId,
    this.groupName,
  });

  static const collection = 'users';

  /// Subcollection thống kê theo ngày: `users/{uid}/dailyStats/{yyyy-MM-dd}`.
  static const dailyStatsCollection = 'dailyStats';

  /// Thưởng cho mỗi câu trả lời đúng.
  ///
  /// Cộng theo từng câu thay vì theo phiên: người học thoát giữa phiên vẫn
  /// giữ được phần thưởng đã kiếm, và không có nguy cơ cộng hai lần khi
  /// màn hình tổng kết bị vẽ lại.
  static const experiencePerCorrectAnswer = 10;
  static const seedsPerCorrectAnswer = 2;

  /// Chuỗi ngày học liên tiếp mới, tính từ `lastActiveDate` trong hồ sơ.
  ///
  /// Ba trường hợp:
  /// - Đã học hôm nay rồi → giữ nguyên, không cộng thêm mỗi câu trả lời.
  /// - Lần cuối là hôm qua → cộng 1.
  /// - Cũ hơn (hoặc chưa từng học) → về 1, chuỗi đã đứt.
  static int nextStreak(
    Map<String, dynamic> userData, {
    required DateTime now,
  }) {
    final current = switch (userData['streakDays']) {
      final num value => value.toInt(),
      _ => 0,
    };
    final lastActive = userData['lastActiveDate'];

    final today = dateKey(now);
    final yesterday = dateKey(now.subtract(const Duration(days: 1)));

    if (lastActive == today) return current < 1 ? 1 : current;
    if (lastActive == yesterday) return current + 1;
    return 1;
  }

  /// Khóa ngày dạng `yyyy-MM-dd` theo múi giờ máy người dùng.
  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  final String name;
  final String avatarUrl;
  final int experience;
  final int streakDays;
  final int seeds;
  final int gems;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final String? groupId;
  final String? groupName;

  /// Hồ sơ khởi tạo cho người dùng vừa đăng ký: mọi số đếm bằng 0.
  factory UserDocument.initialFor(AppUser user) {
    return UserDocument(
      name: user.greetingName,
      avatarUrl: '',
      experience: 0,
      streakDays: 0,
      seeds: 0,
      gems: 0,
      postCount: 0,
      followerCount: 0,
      followingCount: 0,
    );
  }

  factory UserDocument.fromMap(Map<String, dynamic> map) {
    // Đọc có giá trị mặc định: document cũ thiếu field mới sẽ không làm sập
    // trang hồ sơ.
    int readInt(String key) {
      final value = map[key];
      return value is num ? value.toInt() : 0;
    }

    String readString(String key) {
      final value = map[key];
      return value is String ? value : '';
    }

    String? readStringOrNull(String key) {
      final value = map[key];
      return value is String && value.isNotEmpty ? value : null;
    }

    return UserDocument(
      name: readString('name'),
      avatarUrl: readString('avatarUrl'),
      experience: readInt('experience'),
      streakDays: readInt('streakDays'),
      seeds: readInt('seeds'),
      gems: readInt('gems'),
      postCount: readInt('postCount'),
      followerCount: readInt('followerCount'),
      followingCount: readInt('followingCount'),
      groupId: readStringOrNull('groupId'),
      groupName: readStringOrNull('groupName'),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'avatarUrl': avatarUrl,
    'experience': experience,
    'streakDays': streakDays,
    'seeds': seeds,
    'gems': gems,
    'postCount': postCount,
    'followerCount': followerCount,
    'followingCount': followingCount,
    'groupId': groupId,
    'groupName': groupName,
  };

  UserProfile toEntity() => UserProfile(
    name: name,
    avatarAsset: avatarUrl,
    postCount: postCount,
    followerCount: followerCount,
    followingCount: followingCount,
    experience: experience,
    streakDays: streakDays,
    groupName: groupName,
    // Lưới ảnh lấy từ collection `posts`, không nằm trong document này.
    recentPostCount: 0,
  );
}
