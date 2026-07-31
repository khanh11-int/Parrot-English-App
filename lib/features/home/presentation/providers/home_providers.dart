import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/user_data_revision.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_home_repository.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';

/// Dữ liệu trang chủ tổng hợp từ Firestore.
///
/// Test override provider này bằng `HomeMockRepository`.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return FirebaseHomeRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

/// Dữ liệu trang chủ. UI đọc qua `AsyncValue` nên tự có đủ 3 trạng thái
/// đang tải / lỗi / có dữ liệu.
final homeSummaryProvider = FutureProvider<HomeSummary>((ref) {
  // Đổi người đăng nhập thì tải lại, không hiện dữ liệu người trước.
  ref.watch(currentUserProvider);
  // Học xong là XP / hạt / streak đổi ngay trên trang chủ.
  ref.watch(userDataRevisionProvider);
  return ref.watch(homeRepositoryProvider).getSummary();
});
