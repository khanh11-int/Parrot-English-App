import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/vocabulary_topic.dart';
import '../../domain/repositories/topic_repository.dart';

/// Danh sách chủ đề mock, dùng cho test widget.
class TopicMockRepository implements TopicRepository {
  const TopicMockRepository();

  static const _mockDelay = Duration(milliseconds: 400);

  @override
  Future<List<VocabularyTopic>> getTopics() async {
    await Future<void>.delayed(_mockDelay);

    return const [
      VocabularyTopic(
        id: 'health',
        name: 'Sức khoẻ',
        learnedCount: 4,
        totalCount: 18,
        iconAsset: AppAssets.itemHeart,
      ),
      VocabularyTopic(
        id: 'family',
        name: 'Gia đình',
        learnedCount: 12,
        totalCount: 12,
        iconAsset: AppAssets.stickerLove,
      ),
      VocabularyTopic(
        id: 'furniture',
        name: 'Đồ nội thất',
        learnedCount: 15,
        totalCount: 24,
        iconAsset: AppAssets.iconHome,
      ),
      VocabularyTopic(
        id: 'office',
        name: 'Văn phòng',
        learnedCount: 6,
        totalCount: 20,
        iconAsset: AppAssets.iconQuest,
      ),
      VocabularyTopic(
        id: 'technology',
        name: 'Công nghệ',
        learnedCount: 8,
        totalCount: 30,
        iconAsset: AppAssets.itemEnergy,
      ),
      VocabularyTopic(
        id: 'food',
        name: 'Đồ ăn thức uống',
        learnedCount: 0,
        totalCount: 26,
        iconAsset: AppAssets.itemGift,
      ),
      VocabularyTopic(
        id: 'school',
        name: 'Trường học',
        learnedCount: 21,
        totalCount: 22,
        iconAsset: AppAssets.iconStudy,
      ),
    ];
  }
}
