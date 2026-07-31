import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:parrot/core/router/app_router.dart';
import 'package:parrot/core/theme/app_theme.dart';
import 'package:parrot/features/auth/data/repositories/auth_mock_repository.dart';
import 'package:parrot/features/auth/presentation/providers/auth_providers.dart';
import 'package:parrot/features/community/data/repositories/community_mock_repository.dart';
import 'package:parrot/features/community/presentation/providers/community_providers.dart';
import 'package:parrot/features/flashcard/data/repositories/review_mock_repository.dart';
import 'package:parrot/features/flashcard/presentation/providers/review_providers.dart';
import 'package:parrot/features/home/data/repositories/home_mock_repository.dart';
import 'package:parrot/features/home/presentation/providers/home_providers.dart';
import 'package:parrot/features/profile/data/repositories/profile_mock_repository.dart';
import 'package:parrot/features/profile/presentation/providers/profile_providers.dart';
import 'package:parrot/features/quiz/data/repositories/learn_mock_repository.dart';
import 'package:parrot/features/quiz/data/repositories/topic_mock_repository.dart';
import 'package:parrot/features/shop/data/repositories/shop_mock_repository.dart';
import 'package:parrot/features/shop/presentation/providers/shop_providers.dart';
import 'package:parrot/features/quiz/presentation/providers/learn_providers.dart';

/// Dựng app cho test với xác thực giả.
///
/// Bắt buộc override `authRepositoryProvider`: bản thật gọi
/// `FirebaseAuth.instance`, mà `Firebase.initializeApp()` chỉ chạy trong
/// `main()` nên trong test sẽ ném lỗi "No Firebase App has been created".
///
/// Trả về [GoRouter] để test tự điều hướng tới route cần kiểm.
/// [extraOverrides] được áp **sau** danh sách mặc định nên ghi đè được chúng —
/// dùng khi một test cần dữ liệu khác bản mock chung.
Future<GoRouter> pumpParrotApp(
  WidgetTester tester, {
  bool isSignedIn = true,
  List<Override> extraOverrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(
        isSignedIn
            ? AuthMockRepository.signedIn()
            : AuthMockRepository.signedOut(),
      ),
      // Hồ sơ thật đọc Firestore, mà Firestore chưa được khởi tạo trong test.
      profileRepositoryProvider.overrideWithValue(
        const ProfileMockRepository(),
      ),
      topicRepositoryProvider.overrideWithValue(const TopicMockRepository()),
      // Phiên học thật đọc bộ từ trong Firestore; test dùng bộ từ cứng.
      learnRepositoryProvider.overrideWithValue(const LearnMockRepository()),
      shopRepositoryProvider.overrideWithValue(const ShopMockRepository()),
      homeRepositoryProvider.overrideWithValue(const HomeMockRepository()),
      reviewRepositoryProvider.overrideWithValue(const ReviewMockRepository()),
      communityRepositoryProvider.overrideWithValue(
        const CommunityMockRepository(),
      ),
      ...extraOverrides,
    ],
  );
  addTearDown(container.dispose);

  final router = container.read(routerProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await settleMockData(tester);
  return router;
}

/// Chờ cho mọi repository mock trả dữ liệu và UI vẽ xong.
///
/// Phải pump nhiều nhịp: nhịp đầu mount trang mới (lúc này provider mới bắt đầu
/// gọi repository), các nhịp sau mới đẩy hết `Future.delayed` của bản mock. Chỉ
/// pump một nhịp sẽ để lại timer treo và test báo lỗi.
Future<void> settleMockData(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(seconds: 2));
  }
}
