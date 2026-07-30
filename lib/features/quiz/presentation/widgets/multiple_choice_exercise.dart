import 'package:flutter/material.dart';

import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/learn_question.dart';

/// Bài tập trắc nghiệm 4 đáp án.
///
/// Hai bước rõ ràng: chọn đáp án → bấm "Kiểm tra" → xem phản hồi → "Tiếp tục".
/// Không tự chấm ngay khi chọn, để người học còn kịp đổi ý.
class MultipleChoiceExercise extends StatefulWidget {
  const MultipleChoiceExercise({
    super.key,
    required this.data,
    required this.onCompleted,
  });

  final MultipleChoiceExerciseData data;

  /// Gọi khi người học bấm "Tiếp tục", kèm việc trả lời có đúng hay không.
  final ValueChanged<bool> onCompleted;

  @override
  State<MultipleChoiceExercise> createState() => _MultipleChoiceExerciseState();
}

class _MultipleChoiceExerciseState extends State<MultipleChoiceExercise> {
  String? _selectedOption;
  bool _isChecked = false;

  bool get _isCorrect => _selectedOption == widget.data.correctOption;

  void _check() => setState(() => _isChecked = true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.data.question, style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.xl),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final option in widget.data.options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _OptionTile(
                      label: option,
                      state: _stateFor(option),
                      onTap: _isChecked
                          ? null
                          : () => setState(() => _selectedOption = option),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_isChecked) _FeedbackBanner(isCorrect: _isCorrect),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: _isChecked ? AppLabels.continueAction : AppLabels.check,
          onPressed: switch ((_selectedOption, _isChecked)) {
            (null, _) => null,
            (_, false) => _check,
            (_, true) => () => widget.onCompleted(_isCorrect),
          },
        ),
      ],
    );
  }

  _OptionState _stateFor(String option) {
    if (!_isChecked) {
      return option == _selectedOption
          ? _OptionState.selected
          : _OptionState.idle;
    }
    // Sau khi chấm: luôn chỉ ra đáp án đúng, kể cả khi người học chọn sai.
    if (option == widget.data.correctOption) return _OptionState.correct;
    if (option == _selectedOption) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, textColor, icon) = switch (state) {
      _OptionState.idle => (
        AppColors.neutral,
        AppColors.neutral,
        AppColors.textPrimary,
        null,
      ),
      _OptionState.selected => (
        AppColors.primaryLight,
        AppColors.primary,
        AppColors.primaryDark,
        null,
      ),
      _OptionState.correct => (
        AppColors.successSoft,
        AppColors.success,
        AppColors.leafDark,
        Icons.check_circle_rounded,
      ),
      _OptionState.wrong => (
        AppColors.dangerSoft,
        AppColors.danger,
        AppColors.danger,
        Icons.cancel_rounded,
      ),
    };

    return Material(
      color: background,
      borderRadius: AppRadius.buttonBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonBorder,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.buttonBorder,
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(color: textColor),
                ),
              ),
              // Đúng/sai luôn kèm icon, không chỉ dựa vào màu.
              if (icon != null) Icon(icon, size: 20, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dải phản hồi hiện ngay trên nút sau khi chấm.
class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.isCorrect});

  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.successSoft : AppColors.dangerSoft,
        borderRadius: AppRadius.buttonBorder,
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.celebration_rounded : Icons.lightbulb_outline,
            size: 20,
            color: isCorrect ? AppColors.leafDark : AppColors.danger,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isCorrect
                  ? 'Chính xác!'
                  : 'Chưa đúng. Từ này sẽ quay lại ở cuối phiên.',
              style: AppTextStyles.bodyBold.copyWith(
                color: isCorrect ? AppColors.leafDark : AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
