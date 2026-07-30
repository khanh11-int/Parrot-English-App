import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/vocab_card.dart';
import '../../domain/entities/recognized_word.dart';
import '../providers/scan_providers.dart';
import '../widgets/scan_image_preview.dart';
import '../widgets/topic_picker_sheet.dart';

/// Kết quả nhận diện ảnh — mục 5.3 của `UI_SPEC.md`.
///
/// Điểm nhấn của trang: bấm khung trên ảnh thì thẻ từ tương ứng bên dưới được
/// cuộn tới và làm nổi, nên người dùng biết chắc từ nào ứng với vật nào.
class ScanResultPage extends ConsumerStatefulWidget {
  const ScanResultPage({super.key});

  @override
  ConsumerState<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends ConsumerState<ScanResultPage> {
  /// Khoá của từng thẻ từ, dùng để cuộn tới thẻ khi bấm khung trên ảnh.
  final _cardKeys = <String, GlobalKey>{};

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(scanControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả nhận diện')),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            ScanImagePreview(
              imagePath: scan.imagePath,
              words: scan.words,
              areBoxesVisible: scan.areBoxesVisible,
              onToggleBoxes: () => ref
                  .read(scanControllerProvider.notifier)
                  .toggleBoxesVisibility(),
              onWordTap: _onBoxTapped,
              highlightedWordId: scan.highlightedWordId,
            ),
            const SizedBox(height: AppSpacing.lg),
            _BulkTopicRow(
              onPressed: () => _pickTopicForSelected(scan.selectedWords.length),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final word in scan.words) ...[
              VocabCard(
                key: _keyFor(word.id),
                english: word.english,
                vietnamese: word.vietnamese,
                phonetic: word.phonetic,
                topic: word.topicName,
                isSelected: scan.selectedWordIds.contains(word.id),
                isHighlighted: word.id == scan.highlightedWordId,
                onSelectedChanged: (_) => ref
                    .read(scanControllerProvider.notifier)
                    .toggleWordSelection(word.id),
                onSpeak: () => _showComingSoon('Phát âm'),
                onTopicTap: () => _pickTopicForWord(word),
              ),
              const SizedBox(height: AppSpacing.cardGap),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(
        selectedCount: scan.selectedWords.length,
        onSave: () => _save(postToCommunity: false),
        onSaveAndPost: () => _save(postToCommunity: true),
      ),
    );
  }

  GlobalKey _keyFor(String wordId) =>
      _cardKeys.putIfAbsent(wordId, GlobalKey.new);

  void _onBoxTapped(RecognizedWord word) {
    ref.read(scanControllerProvider.notifier).highlightWord(word.id);

    final context = _keyFor(word.id).currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
  }

  Future<void> _pickTopicForWord(RecognizedWord word) async {
    final topic = await showTopicPickerSheet(
      context,
      title: 'Chủ đề cho "${word.english}"',
      currentTopicId: word.topicId,
    );
    if (topic == null) return;
    ref.read(scanControllerProvider.notifier).setTopic(word.id, topic);
  }

  Future<void> _pickTopicForSelected(int selectedCount) async {
    if (selectedCount == 0) {
      _showMessage('Chưa chọn từ nào để gán chủ đề.');
      return;
    }

    final topic = await showTopicPickerSheet(
      context,
      title: 'Chủ đề cho $selectedCount từ đang chọn',
    );
    if (topic == null) return;
    ref.read(scanControllerProvider.notifier).setTopicForSelected(topic);
  }

  Future<void> _save({required bool postToCommunity}) async {
    final count = ref.read(scanControllerProvider).selectedWords.length;
    final error = await ref
        .read(scanControllerProvider.notifier)
        .saveSelectedWords(shouldPost: postToCommunity);

    // Lưu là lời gọi mạng nên phải kiểm `mounted` lại sau `await`.
    if (!mounted) return;

    // Lỗi thì giữ nguyên trang để người dùng bấm lưu lại, không mất công chọn
    // từ và gán chủ đề từ đầu.
    if (error != null) {
      _showMessage(error);
      return;
    }

    ref.read(scanControllerProvider.notifier).reset();
    _showMessage(
      postToCommunity
          ? 'Đã lưu $count từ và đăng lên cộng đồng.'
          : 'Đã lưu $count từ.',
    );
    Navigator.of(context).pop();
  }

  void _showComingSoon(String feature) =>
      _showMessage('$feature sẽ có ở bản sau.');

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: AppDurations.snackBar),
      );
  }
}

/// Hàng "Chọn chủ đề cho tất cả" — gán một lần cho mọi từ đang chọn.
class _BulkTopicRow extends StatelessWidget {
  const _BulkTopicRow({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text('Chọn chủ đề cho tất cả:', style: AppTextStyles.body),
        ),
        const SizedBox(width: AppSpacing.sm),
        SecondaryButton(
          label: AppLabels.chooseTopic,
          onPressed: onPressed,
          isExpanded: false,
        ),
      ],
    );
  }
}

/// Thanh cố định dưới đáy với 2 hành động lưu.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.selectedCount,
    required this.onSave,
    required this.onSaveAndPost,
  });

  final int selectedCount;
  final VoidCallback onSave;
  final VoidCallback onSaveAndPost;

  @override
  Widget build(BuildContext context) {
    // Cả hai nút vô hiệu khi chưa chọn từ nào — bấm lưu 0 từ không có ý nghĩa.
    final isEnabled = selectedCount > 0;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        // Cộng thêm vùng an toàn dưới để nút không bị thanh hệ thống che.
        bottom: AppSpacing.md + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: AppLabels.saveVocabulary,
              onPressed: isEnabled ? onSave : null,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SecondaryButton(
              label: AppLabels.saveAndPost,
              onPressed: isEnabled ? onSaveAndPost : null,
            ),
          ),
        ],
      ),
    );
  }
}
