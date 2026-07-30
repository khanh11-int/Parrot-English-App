import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/presentation/providers/profile_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: ParrotApp()));
}

class ParrotApp extends ConsumerWidget {
  const ParrotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theo dõi để hồ sơ Firestore được tạo ngay khi có người đăng nhập.
    // Provider này không trả giá trị, chỉ cần sống suốt vòng đời app.
    ref.watch(profileBootstrapProvider);

    // Router nằm trong provider để `redirect` đọc được trạng thái đăng nhập.
    // Provider giữ nguyên instance nên lịch sử điều hướng không bị mất khi
    // widget rebuild.
    return MaterialApp.router(
      title: 'Parrot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
