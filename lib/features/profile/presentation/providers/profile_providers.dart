import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/user_data_revision.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Hồ sơ đọc từ Firestore.
///
/// Test override provider này bằng `ProfileMockRepository`.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirebaseProfileRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

final userProfileProvider = FutureProvider<UserProfile>((ref) {
  // Đổi người đăng nhập thì tải lại hồ sơ, không hiện dữ liệu người trước.
  ref.watch(currentUserProvider);
  // Học xong là XP / streak / hạng đổi ngay, không cần bấm Làm mới.
  ref.watch(userDataRevisionProvider);
  return ref.watch(profileRepositoryProvider).getProfile();
});

/// Tạo document `users/{uid}` ngay khi có người đăng nhập.
///
/// Phải được `watch` ở gốc app mới sống suốt vòng đời. Không gộp vào
/// `AuthController` để feature `auth` không phải biết đến feature `profile`.
final profileBootstrapProvider = Provider<void>((ref) {
  ref.listen(authStateProvider, (previous, next) async {
    final user = next.valueOrNull;
    if (user == null) return;

    try {
      await ref.read(profileRepositoryProvider).ensureProfile(user);
      // Tên vừa được đồng bộ xuống `users/{uid}.name`. Hồ sơ, trang chủ và bảng
      // xếp hạng đều đọc field đó nên phải bảo chúng tải lại — nếu không, đổi
      // tên xong vẫn thấy tên cũ tới lần mở app sau.
      ref.read(userDataRevisionProvider.notifier).bump();
    } on Failure catch (failure) {
      // Không đẩy lỗi ra UI: người dùng vừa đăng nhập xong, chặn họ lại vì một
      // lần ghi thất bại là vô lý. `getProfile` cũng tự tạo lại nếu còn thiếu.
      debugPrint('Không tạo được hồ sơ người dùng: ${failure.message}');
    }
  }, fireImmediately: true);
});
