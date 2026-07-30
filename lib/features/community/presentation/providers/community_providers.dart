import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_community_repository.dart';
import '../../domain/entities/community_entities.dart';
import '../../domain/repositories/community_repository.dart';

/// Dữ liệu Cộng đồng đọc từ Firestore.
///
/// Test override provider này bằng `CommunityMockRepository`.
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return FirebaseCommunityRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

/// Dòng thời gian, kèm các thao tác thích / lưu bài.
class FeedController extends AsyncNotifier<List<CommunityPost>> {
  @override
  Future<List<CommunityPost>> build() {
    return ref.read(communityRepositoryProvider).getFeed();
  }

  /// Đổi trạng thái thích.
  ///
  /// Cập nhật state trước rồi mới gọi API (optimistic update): người dùng thấy
  /// tim đổi màu ngay. Nếu API lỗi thì **hoàn tác** để UI không nói dối về
  /// trạng thái đã lưu trên server.
  Future<void> toggleLike(String postId) async {
    final post = _find(postId);
    if (post == null) return;

    final target = !post.isLiked;
    _replace(
      post.copyWith(
        isLiked: target,
        likeCount: post.likeCount + (target ? 1 : -1),
      ),
    );

    try {
      final updated = await ref
          .read(communityRepositoryProvider)
          .setLiked(postId, isLiked: target);
      _replace(updated);
    } on Failure catch (failure) {
      debugPrint('Không thích được bài đăng: ${failure.message}');
      _replace(post);
    }
  }

  /// Đổi trạng thái lưu bài, cùng cách làm như [toggleLike].
  Future<void> toggleBookmark(String postId) async {
    final post = _find(postId);
    if (post == null) return;

    final target = !post.isBookmarked;
    _replace(
      post.copyWith(
        isBookmarked: target,
        bookmarkCount: post.bookmarkCount + (target ? 1 : -1),
      ),
    );

    try {
      final updated = await ref
          .read(communityRepositoryProvider)
          .setBookmarked(postId, isBookmarked: target);
      _replace(updated);
    } on Failure catch (failure) {
      debugPrint('Không lưu được bài đăng: ${failure.message}');
      _replace(post);
    }
  }

  CommunityPost? _find(String postId) =>
      state.valueOrNull?.where((post) => post.id == postId).firstOrNull;

  void _replace(CommunityPost updated) {
    final posts = state.valueOrNull;
    if (posts == null) return;

    state = AsyncData([
      for (final post in posts)
        if (post.id == updated.id) updated else post,
    ]);
  }
}

final feedProvider = AsyncNotifierProvider<FeedController, List<CommunityPost>>(
  FeedController.new,
);

final leaderboardProvider = FutureProvider<Leaderboard>((ref) {
  // Đổi người đăng nhập thì tải lại: hàng "của tôi" trên bảng phải đúng người.
  ref.watch(currentUserProvider);
  return ref.watch(communityRepositoryProvider).getLeaderboard();
});

final studyGroupProvider = FutureProvider<StudyGroup?>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(communityRepositoryProvider).getStudyGroup();
});
