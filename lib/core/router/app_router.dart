import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/community/presentation/pages/community_page.dart';
import '../../features/flashcard/presentation/pages/review_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/image_scan/presentation/pages/scan_page.dart';
import '../../features/image_scan/presentation/pages/scan_result_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/quiz/presentation/pages/session_page.dart';
import '../../features/quiz/presentation/pages/topic_list_page.dart';
import '../../features/quiz/presentation/providers/learn_providers.dart';
import '../../features/shop/presentation/pages/shop_page.dart';
import '../../features/vocabulary/presentation/pages/saved_words_page.dart';
import '../../shared/widgets/app_shell.dart';
import 'app_routes.dart';

/// Cầu nối giữa một `Stream` và `GoRouter.refreshListenable`.
///
/// `GoRouter` chỉ chạy lại `redirect` khi được thông báo. Nhờ lớp này, lúc đăng
/// nhập hoặc đăng xuất router tự đánh giá lại và điều hướng, UI không phải gọi
/// `context.go` bằng tay.
class _StreamRefresh extends ChangeNotifier {
  _StreamRefresh(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Router của app.
///
/// Đặt trong provider để `redirect` đọc được trạng thái đăng nhập. Provider chỉ
/// phụ thuộc `authRepositoryProvider` (không đổi trong một lần chạy app) nên
/// router **không bị tạo lại**, lịch sử điều hướng giữ nguyên.
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final refresh = _StreamRefresh(authRepository.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final isSignedIn = authRepository.currentUser != null;
      final isPublic = AppRoutes.publicRoutes.contains(state.matchedLocation);

      // Chưa đăng nhập mà vào trang bên trong → đẩy về trang đăng nhập.
      if (!isSignedIn && !isPublic) return AppRoutes.login;
      // Đã đăng nhập mà còn ở trang đăng nhập → đưa vào app.
      if (isSignedIn && isPublic) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branch(AppRoutes.home, (_, _) => const HomePage()),
          _branch(AppRoutes.review, (_, _) => const ReviewPage()),
          _branch(AppRoutes.community, (_, _) => const CommunityPage()),
          _branch(AppRoutes.profile, (_, _) => const ProfilePage()),
        ],
      ),
      GoRoute(path: AppRoutes.scan, builder: (_, _) => const ScanPage()),
      GoRoute(
        path: AppRoutes.scanResult,
        builder: (_, _) => const ScanResultPage(),
      ),
      GoRoute(
        path: AppRoutes.learnTopics,
        builder: (_, _) => const TopicListPage(),
      ),
      GoRoute(
        path: AppRoutes.learnSession,
        builder: (_, state) => SessionPage(
          mode: SessionMode.learn,
          topicId: state.uri.queryParameters[AppRoutes.topicIdParam],
        ),
      ),
      GoRoute(
        path: AppRoutes.reviewSession,
        builder: (_, _) => const SessionPage(mode: SessionMode.review),
      ),
      GoRoute(path: AppRoutes.shop, builder: (_, _) => const ShopPage()),
      GoRoute(
        path: AppRoutes.savedWords,
        builder: (_, _) => const SavedWordsPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsPage(),
      ),
    ],
  );
});

StatefulShellBranch _branch(String path, GoRouterWidgetBuilder build) {
  return StatefulShellBranch(
    routes: [GoRoute(path: path, builder: build)],
  );
}
