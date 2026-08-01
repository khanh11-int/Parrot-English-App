import 'package:flutter/material.dart';

import '../../../../core/constants/app_labels.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/word_pair.dart';

/// Bài tập nối cặp từ Anh ↔ Việt.
///
/// Cột phải được xáo trộn theo một thứ tự **cố định trong suốt vòng** (xáo lại
/// mỗi lần rebuild sẽ khiến ô nhảy chỗ ngay dưới ngón tay người học).
class MatchPairsExercise extends StatefulWidget {
  const MatchPairsExercise({
    super.key,
    required this.data,
    required this.onCompleted,
    required this.onWrongAnswer,
  });

  final MatchPairsExerciseData data;
  final VoidCallback onCompleted;
  final VoidCallback onWrongAnswer;

  @override
  State<MatchPairsExercise> createState() => _MatchPairsExerciseState();
}

class _MatchPairsExerciseState extends State<MatchPairsExercise> {
  late final List<WordPair> _shuffledMeanings = _shuffleMeanings();

  String? _selectedEnglishId;
  String? _wrongEnglishId;
  String? _wrongMeaningId;
  final _matchedIds = <String>{};

  List<WordPair> _shuffleMeanings() {
    // Đảo thứ tự bằng cách xếp lẻ trước, chẵn sau: đủ để nghĩa không nằm ngang
    // hàng với từ tương ứng, mà vẫn cho ra kết quả xác định (dễ test).
    final pairs = widget.data.pairs;
    return [
      for (var i = 1; i < pairs.length; i += 2) pairs[i],
      for (var i = 0; i < pairs.length; i += 2) pairs[i],
    ];
  }

  bool get _isAllMatched => _matchedIds.length == widget.data.pairs.length;

  void _onEnglishTap(WordPair pair) {
    if (_matchedIds.contains(pair.id)) return;
    setState(() => _selectedEnglishId = pair.id);
  }

  void _onMeaningTap(WordPair pair) {
    if (_matchedIds.contains(pair.id)) return;

    final selectedId = _selectedEnglishId;
    if (selectedId == null) return;

    if (selectedId == pair.id) {
      setState(() {
        _matchedIds.add(pair.id);
        _selectedEnglishId = null;
      });
      return;
    }

    widget.onWrongAnswer();
    setState(() {
      _wrongEnglishId = selectedId;
      _wrongMeaningId = pair.id;
    });

    // Nháy đỏ rồi tự bỏ chọn, để người học thấy phản hồi mà không phải bấm gì.
    Future<void>.delayed(AppDurations.wrongAnswerFlash, () {
      if (!mounted) return;
      setState(() {
        _wrongEnglishId = null;
        _wrongMeaningId = null;
        _selectedEnglishId = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ExerciseKind.matchPairs.instruction,
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (final pair in widget.data.pairs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _PairTile(
                            label: pair.english,
                            state: _stateFor(
                              pair.id,
                              isSelected: pair.id == _selectedEnglishId,
                              isWrong: pair.id == _wrongEnglishId,
                            ),
                            onTap: () => _onEnglishTap(pair),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    children: [
                      for (final pair in _shuffledMeanings)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _PairTile(
                            label: pair.vietnamese,
                            state: _stateFor(
                              pair.id,
                              isSelected: false,
                              isWrong: pair.id == _wrongMeaningId,
                            ),
                            onTap: () => _onMeaningTap(pair),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: AppLabels.continueAction,
          onPressed: _isAllMatched ? widget.onCompleted : null,
        ),
      ],
    );
  }

  _PairTileState _stateFor(
    String pairId, {
    required bool isSelected,
    required bool isWrong,
  }) {
    if (_matchedIds.contains(pairId)) return _PairTileState.matched;
    if (isWrong) return _PairTileState.wrong;
    if (isSelected) return _PairTileState.selected;
    return _PairTileState.idle;
  }
}

enum _PairTileState { idle, selected, matched, wrong }

class _PairTile extends StatelessWidget {
  const _PairTile({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _PairTileState state;
  final VoidCallback onTap;

  static const _height = 48.0;

  @override
  Widget build(BuildContext context) {
    final (background, border, textColor) = switch (state) {
      _PairTileState.idle => (
        AppColors.successSoft,
        AppColors.successSoft,
        AppColors.textPrimary,
      ),
      _PairTileState.selected => (
        AppColors.primaryLight,
        AppColors.primary,
        AppColors.primaryDark,
      ),
      _PairTileState.matched => (
        AppColors.success,
        AppColors.success,
        AppColors.textOnPrimary,
      ),
      _PairTileState.wrong => (
        AppColors.dangerSoft,
        AppColors.danger,
        AppColors.danger,
      ),
    };

    return AnimatedOpacity(
      // Cặp đã ghép mờ dần đi để mắt tập trung vào các cặp còn lại.
      opacity: state == _PairTileState.matched ? 0.5 : 1,
      duration: AppDurations.fast,
      child: Material(
        color: background,
        borderRadius: AppRadius.buttonBorder,
        child: InkWell(
          onTap: state == _PairTileState.matched ? null : onTap,
          borderRadius: AppRadius.buttonBorder,
          child: Container(
            height: _height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.buttonBorder,
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ghép đúng có thêm dấu ✓, không chỉ đổi màu.
                if (state == _PairTileState.matched) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
