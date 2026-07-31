import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/home_summary.dart';
import '../providers/home_providers.dart';
import '../widgets/currency_header.dart';
import '../widgets/goal_card.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/quest_card.dart';

/// Trang chủ — mục 5.1 của `docs/UI_SPEC.md`.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    // Đổi tên thì `authStateChanges` phát lại → hồ sơ đồng bộ xuống Firestore →
    // bộ đếm `userDataRevision` được bump → lời chào ở đây tự đổi theo.
    ref.watch(currentUserProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(homeSummaryProvider.future),
        child: AsyncValueView(
          value: summaryAsync,
          loading: const HomeSkeleton(),
          onRetry: () => ref.invalidate(homeSummaryProvider),
          data: (summary) => _HomeContent(summary: summary),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListView(
      // `always` để kéo-làm-mới vẫn hoạt động khi nội dung ngắn hơn màn hình.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        CurrencyHeader(
          userName: summary.userName,
          streakDays: summary.streakDays,
          gemCount: summary.gemCount,
          seedCount: summary.seedCount,
          onShopPressed: () => context.push(AppRoutes.shop),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _GoalRow(),
        const SizedBox(height: AppSpacing.xl),
        // Hai mục tách tên rõ ràng thay vì gộp dưới một chữ "Nhiệm vụ": việc
        // hôm nay và tiến độ dài hạn là hai chuyện, người dùng đọc theo hai kiểu
        // khác nhau.
        const SectionHeader(title: 'Hôm nay'),
        QuestCard(group: summary.dailyQuests),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Hành trình'),
        JourneyCard(
          learnedCount: summary.learnedWordCount,
          totalCount: summary.totalWordCount,
          percent: summary.curriculumPercent,
          progress: summary.curriculumProgress,
          onTap: () => context.push(AppRoutes.learnTopics),
        ),
      ],
    );
  }
}

/// Hai thẻ hành động xếp cạnh nhau, chia đều chiều ngang.
///
/// Nhãn là hằng số, không lấy từ dữ liệu: đây là tên hai chỗ đi tới, không phải
/// số liệu. Trước đây chúng đọc `summary.learnGoal.title` / `reviewGoal.title` —
/// server trả về hai chuỗi cố định, còn phần số của hai mục tiêu đó thì bị bỏ
/// (trùng với hai nhiệm vụ trong mục "Hôm nay").
class _GoalRow extends StatelessWidget {
  const _GoalRow();

  @override
  Widget build(BuildContext context) {
    // `IntrinsicHeight` để hai thẻ luôn cao bằng nhau dù nhãn dài ngắn khác
    // nhau. Không dùng `stretch` trực tiếp: trong `ListView` chiều cao không
    // giới hạn nên `stretch` sẽ ném lỗi ràng buộc vô hạn.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GoalCard(
              label: AppLabels.learnNewWords,
              mascotAsset: AppAssets.mascotReading,
              style: GoalCardStyle.primary,
              // Không vào thẳng phiên học: mở danh sách chủ đề để người học tự
              // chọn học chủ đề nào.
              onTap: () => context.push(AppRoutes.learnTopics),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: GoalCard(
              label: AppLabels.reviewNow,
              mascotAsset: AppAssets.mascotPhone,
              style: GoalCardStyle.leaf,
              // Sang **tab** Ôn tập, không nhảy thẳng vào phiên — đối xứng với
              // thẻ bên cạnh. Tab đó mới cho thấy bộ nào đến hạn và cho ôn riêng
              // từng chủ đề; nhảy thẳng vào phiên là bỏ qua hết.
              onTap: () => context.go(AppRoutes.review),
            ),
          ),
        ],
      ),
    );
  }
}
