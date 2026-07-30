import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/vocabulary_topic.dart';

/// Ánh xạ document Firestore `topics/{topicId}`.
///
/// Document **không** chứa số từ đã học: đó là dữ liệu riêng của từng người,
/// nằm ở `users/{uid}/topicProgress/{topicId}`.
class TopicDocument {
  const TopicDocument({
    required this.id,
    required this.name,
    required this.wordCount,
    required this.order,
  });

  static const collection = 'topics';

  /// Subcollection lưu tiến độ của người dùng cho từng chủ đề.
  static const progressCollection = 'topicProgress';

  final String id;
  final String name;

  /// Tổng số từ có trong chủ đề.
  final int wordCount;

  /// Thứ tự hiển thị trong danh sách.
  final int order;

  factory TopicDocument.fromMap(String id, Map<String, dynamic> map) {
    // `trim()` vì dữ liệu nhập tay qua Console rất dễ dính khoảng trắng hoặc
    // tab ở đầu/cuối khi copy-paste.
    final rawName = map['name'] is String
        ? (map['name'] as String).trim()
        : map['name'];
    final rawWordCount = map['wordCount'];
    final rawOrder = map['order'];

    return TopicDocument(
      id: id,
      // Thiếu tên thì lấy id làm tên thay vì để trang trống trơn.
      name: rawName is String && rawName.isNotEmpty ? rawName : id,
      wordCount: rawWordCount is num ? rawWordCount.toInt() : 0,
      order: rawOrder is num ? rawOrder.toInt() : 0,
    );
  }

  VocabularyTopic toEntity({required int learnedCount}) {
    return VocabularyTopic(
      id: id,
      name: name,
      learnedCount: learnedCount,
      totalCount: wordCount,
      iconAsset: iconAssetFor(id),
    );
  }

  /// Ảnh của chủ đề lấy từ asset trong app theo id.
  ///
  /// Cố ý không lưu `iconUrl` trên Firestore: ảnh đang nằm sẵn trong app nên
  /// hiện được ngay, không phải upload lên Storage và không tốn lượt tải mạng.
  /// Khi nào có bộ icon riêng cho chủ đề thì thêm field `iconUrl` sau.
  static String iconAssetFor(String topicId) {
    return switch (topicId) {
      'health' => AppAssets.itemHeart,
      'family' => AppAssets.stickerLove,
      'furniture' => AppAssets.iconHome,
      'office' => AppAssets.iconQuest,
      'technology' => AppAssets.itemEnergy,
      'food' => AppAssets.itemGift,
      'school' => AppAssets.iconStudy,
      // Chủ đề mới chưa được gán ảnh vẫn hiện được, dùng ảnh chung.
      _ => AppAssets.itemTarget,
    };
  }
}
