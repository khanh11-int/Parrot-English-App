import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../quiz/domain/entities/vocabulary_topic.dart';
import '../providers/scan_providers.dart';

/// Bottom sheet chọn chủ đề cho từ vựng.
///
/// Trả về tên chủ đề đã chọn, hoặc `null` nếu người dùng đóng sheet.
Future<VocabularyTopic?> showTopicPickerSheet(
  BuildContext context, {
  required String title,
  String? currentTopicId,
}) {
  return showModalBottomSheet<VocabularyTopic>(
    context: context,
    showDragHandle: true,
    builder: (_) =>
        _TopicPickerSheet(title: title, currentTopicId: currentTopicId),
  );
}

class _TopicPickerSheet extends ConsumerWidget {
  const _TopicPickerSheet({required this.title, this.currentTopicId});

  final String title;
  final String? currentTopicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(scanTopicsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpacing.pagePadding,
              child: Text(title, style: AppTextStyles.titleMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            switch (topicsAsync) {
              AsyncValue(hasError: true) => const Padding(
                padding: AppSpacing.pagePadding,
                child: Text(
                  'Không tải được danh sách chủ đề.',
                  style: AppTextStyles.body,
                ),
              ),
              AsyncValue(:final valueOrNull?) => Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final topic in valueOrNull)
                      _TopicRow(
                        topic: topic,
                        isSelected: topic.id == currentTopicId,
                      ),
                  ],
                ),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.topic, required this.isSelected});

  final VocabularyTopic topic;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(topic.name, style: AppTextStyles.body),
      subtitle: Text('${topic.totalCount} từ', style: AppTextStyles.caption),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: () => Navigator.of(context).pop(topic),
    );
  }
}
