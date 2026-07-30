import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';

/// Dữ liệu trang chủ dạng mock, dùng khi chưa khai báo `PARROT_API_BASE_URL`.
///
/// Giữ lại để người làm UI không bị chặn khi backend chưa xong, và để test
/// widget chạy được mà không cần server.
class HomeMockRepository implements HomeRepository {
  const HomeMockRepository();

  /// Độ trễ giả lập gọi mạng, để thấy được trạng thái skeleton khi phát triển.
  static const _mockDelay = Duration(milliseconds: 600);

  @override
  Future<HomeSummary> getSummary() async {
    await Future<void>.delayed(_mockDelay);

    return const HomeSummary(
      userName: 'Công Tình',
      streakDays: 1,
      gemCount: 2,
      seedCount: 15,
      learnGoal: DailyGoal(title: 'Học từ mới', completed: 9, target: 15),
      reviewGoal: DailyGoal(title: 'Ôn tập ngay', completed: 1, target: 30),
      monthlyQuest: QuestGroup(
        title: 'Nhiệm vụ tháng Chín',
        quests: [
          Quest(title: 'Học 300 từ trong tháng', completed: 45, target: 300),
        ],
      ),
      dailyQuests: QuestGroup(
        title: 'Nhiệm vụ hằng ngày',
        quests: [
          Quest(title: 'Lưu 5 từ mới qua hình ảnh', completed: 3, target: 5),
          Quest(title: 'Ôn tập 30 từ vựng', completed: 0, target: 30),
          Quest(
            title: 'Đăng hình ảnh lên cộng đồng 1 lần',
            completed: 0,
            target: 1,
          ),
        ],
      ),
    );
  }
}
