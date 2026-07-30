import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
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
import '../widgets/scan_banner.dart';

/// Trang chủ — mục 5.1 của `UI_SPEC.md`.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    // Tên người đang đăng nhập là nguồn đáng tin nhất, ưu tiên hơn tên trong
    // dữ liệu trang chủ: đổi tên trong hồ sơ là thấy đổi ngay ở đây.
    final userName = ref.watch(currentUserProvider)?.greetingName;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(homeSummaryProvider.future),
        child: AsyncValueView(
          value: summaryAsync,
          loading: const HomeSkeleton(),
          onRetry: () => ref.invalidate(homeSummaryProvider),
          data: (summary) => _HomeContent(summary: summary, userName: userName),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.summary, this.userName});

  final HomeSummary summary;

  /// Tên người đang đăng nhập; `null` thì dùng tên trong dữ liệu trang chủ.
  final String? userName;

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
          userName: userName ?? summary.userName,
          streakDays: summary.streakDays,
          gemCount: summary.gemCount,
          seedCount: summary.seedCount,
          onShopPressed: () => context.push(AppRoutes.shop),
        ),
        const SizedBox(height: AppSpacing.lg),
        ScanBanner(onPressed: () => context.push(AppRoutes.scan)),
        const SizedBox(height: AppSpacing.lg),
        _GoalRow(summary: summary),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Nhiệm vụ'),
        MonthlyQuestBar(group: summary.monthlyQuest),
        const SizedBox(height: AppSpacing.cardGap),
        QuestCard(group: summary.dailyQuests),
      ],
    );
  }
}

/// Hai thẻ mục tiêu xếp cạnh nhau, chia đều chiều ngang.
class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.summary});

  final HomeSummary summary;

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
              label: summary.learnGoal.title,
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
              label: summary.reviewGoal.title,
              mascotAsset: AppAssets.mascotPhone,
              style: GoalCardStyle.leaf,
              onTap: () => context.push(AppRoutes.reviewSession),
            ),
          ),
        ],
      ),
    );
  }
}
