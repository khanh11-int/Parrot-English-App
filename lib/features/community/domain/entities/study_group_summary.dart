/// Một nhóm trong danh sách nhóm **có thể tham gia**.
///
/// Tách khỏi `StudyGroup` chứ không dùng chung một kiểu: đây là bản đọc rút gọn
/// cho danh sách khám phá, không có XP nhóm hay mốc thành tích vì màn hình đó
/// không cần — và người xem chưa vào nhóm nên cũng không có quyền đọc.
class StudyGroupSummary {
  const StudyGroupSummary({
    required this.id,
    required this.name,
    required this.leaderName,
    required this.memberCount,
  });

  final String id;
  final String name;
  final String leaderName;
  final int memberCount;
}
