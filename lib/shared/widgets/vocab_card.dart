import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'topic_chip.dart';

/// Thẻ hiển thị một từ vựng — widget dùng lại nhiều nhất trong app.
///
/// Xuất hiện ở màn hình Kết quả nhận diện (có ô chọn để lưu) và trong bài đăng ở
/// Cộng đồng (kèm nút lưu về bộ từ của mình).
class VocabCard extends StatelessWidget {
  const VocabCard({
    super.key,
    required this.english,
    required this.vietnamese,
    required this.phonetic,
    required this.onTopicTap,
    this.topic,
    this.isSelected = false,
    this.onSelectedChanged,
    this.isHighlighted = false,
    this.trailingAction,
  });

  final String english;
  final String vietnamese;
  final String phonetic;
  final VoidCallback onTopicTap;
  final String? topic;

  /// Đang được tick để lưu.
  final bool isSelected;

  /// `null` thì thẻ không có ô chọn (biến thể dùng trong bài đăng).
  final ValueChanged<bool>? onSelectedChanged;

  /// Bật khi người dùng bấm vào khung tương ứng trên ảnh — thẻ nháy viền để
  /// người dùng thấy ngay từ nào ứng với vật thể vừa bấm.
  final bool isHighlighted;

  /// Widget thêm ở đáy thẻ, ví dụ nút "Lưu từ vựng" trong bài đăng.
  final Widget? trailingAction;

  @override
  Widget build(BuildContext context) {
    final isEmphasized = isSelected || isHighlighted;
    final hasCheckbox = onSelectedChanged != null;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isEmphasized ? AppColors.primaryLight : AppColors.bgBase,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(
          color: isEmphasized ? AppColors.primary : AppColors.divider,
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.cardBorder,
        child: InkWell(
          onTap: hasCheckbox ? () => onSelectedChanged!(!isSelected) : null,
          borderRadius: AppRadius.cardBorder,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasCheckbox) _SelectionMark(isSelected: isSelected),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(english, style: AppTextStyles.wordEnglish),
                          const SizedBox(height: AppSpacing.xs),
                          // Ghép IPA và nghĩa trên cùng một dòng cho gọn, cắt
                          // bớt khi tên dài thay vì đẩy nút loa ra khỏi thẻ.
                          Text(
                            '$phonetic – $vietnamese',
                            style: AppTextStyles.wordMeaning,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    if (hasCheckbox)
                      const SizedBox(width: _SelectionMark.width),
                    Text('Chủ đề: ', style: AppTextStyles.caption),
                    TopicChip(topic: topic, onTap: onTopicTap),
                  ],
                ),
                if (trailingAction != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  trailingAction!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ô tròn tick chọn từ để lưu.
///
/// Chỉ hiển thị trạng thái; việc bấm do `InkWell` bọc cả thẻ đảm nhận nên vùng
/// chạm rộng hơn, dễ bấm hơn là chỉ tick vào ô tròn nhỏ.
class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.isSelected});

  final bool isSelected;

  /// Bề rộng chiếm chỗ, dùng để thụt lề các dòng bên dưới cho thẳng hàng.
  static const width = 32.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: Alignment.topLeft,
        child: Icon(
          isSelected
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 22,
          color: isSelected ? AppColors.primary : AppColors.textDisabled,
        ),
      ),
    );
  }
}
