import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_linear_progress.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../domain/entities/exercise.dart';
import '../providers/learn_providers.dart';
import '../widgets/match_pairs_exercise.dart';
import '../widgets/multiple_choice_exercise.dart';
import 'session_summary_page.dart';

/// Trang chạy một phiên học hoặc ôn tập — mục 5.4 và 5.5 của `docs/UI_SPEC.md`.
///
/// Hai luồng dùng cùng một trang, chỉ khác provider nguồn từ, nên mọi sửa đổi
/// về bài tập tự động áp dụng cho cả hai.
class SessionPage extends ConsumerWidget {
  const SessionPage({super.key, required this.mode, this.topicId});

  final SessionMode mode;

  /// Chủ đề được chọn; `null` là học trộn mọi chủ đề hoặc phiên ôn tập.
  final String? topicId;

  SessionKey get _key => (mode: mode, topicId: topicId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = sessionProvider(_key);
    final progressAsync = ref.watch(provider);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text(_titleFor(progressAsync.valueOrNull)),
        bottom: _RoundProgressBar(progress: progressAsync.valueOrNull),
      ),
      body: SafeArea(
        child: AsyncValueView(
          value: progressAsync,
          onRetry: () => ref.invalidate(provider),
          data: (progress) => progress.isFinished
              ? SessionSummaryPage(result: progress.toResult())
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _ExerciseSlot(
                    exercise: progress.currentExercise,
                    controller: ref.read(provider.notifier),
                  ),
                ),
        ),
      ),
    );
  }

  String _titleFor(SessionProgress? progress) {
    final baseTitle = switch (mode) {
      SessionMode.learn => 'Học từ mới',
      SessionMode.review => 'Ôn tập',
    };
    if (progress == null || progress.isFinished) return baseTitle;
    return '$baseTitle: vòng ${progress.currentRound}/${progress.totalRounds}';
  }
}

/// Thanh tiến độ mảnh ngay dưới AppBar.
class _RoundProgressBar extends StatelessWidget implements PreferredSizeWidget {
  const _RoundProgressBar({required this.progress});

  final SessionProgress? progress;

  @override
  Size get preferredSize => const Size.fromHeight(AppSpacing.sm);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AppLinearProgress(value: progress?.progress ?? 0, height: 6),
    );
  }
}

/// Chọn widget bài tập theo dạng vòng hiện tại.
class _ExerciseSlot extends StatelessWidget {
  const _ExerciseSlot({required this.exercise, required this.controller});

  final Exercise exercise;
  final SessionController controller;

  @override
  Widget build(BuildContext context) {
    return switch (exercise) {
      final MatchPairsExerciseData data => MatchPairsExercise(
        // Key theo nội dung vòng để sang vòng mới widget được dựng lại từ đầu,
        // không giữ lại lựa chọn của vòng trước.
        key: ValueKey(data),
        data: data,
        onWrongAnswer: controller.recordWrongAnswer,
        onCompleted: () => controller.completeRound(isCorrect: true),
      ),
      final MultipleChoiceExerciseData data => MultipleChoiceExercise(
        key: ValueKey(data),
        data: data,
        onCompleted: (isCorrect) =>
            controller.completeRound(isCorrect: isCorrect),
      ),
    };
  }
}

/// Hiển thị số vòng còn lại, dùng trong AppBar của phiên ôn tập.
class RemainingRoundsLabel extends StatelessWidget {
  const RemainingRoundsLabel({super.key, required this.progress});

  final SessionProgress progress;

  @override
  Widget build(BuildContext context) {
    final remaining = progress.totalRounds - progress.currentIndex;
    return Text('còn $remaining từ', style: AppTextStyles.caption);
  }
}
