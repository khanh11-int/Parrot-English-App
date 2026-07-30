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

/// Luong tin nhan: chat nhom hay binh luan bai dang.
enum MessageThreadKind { group, post }

/// Khoa cua mot luong tin nhan.
typedef MessageThreadKey = ({MessageThreadKind kind, String id});

/// Tin nhan cua mot luong, cap nhat lien tuc.
///
/// Dung `StreamProvider` chu khong phai `FutureProvider`: chat phai thay tin
/// nguoi khac gui ngay, khong phai keo de lam moi.
final messageThreadProvider =
    StreamProvider.family<List<ChatMessage>, MessageThreadKey>((ref, key) {
      final repository = ref.watch(communityRepositoryProvider);
      return switch (key.kind) {
        MessageThreadKind.group => repository.watchGroupMessages(key.id),
        MessageThreadKind.post => repository.watchPostComments(key.id),
      };
    });

/// Gui tin nhan / binh luan.
class MessageSender {
  const MessageSender(this._ref);

  final Ref _ref;

  /// Tra `null` neu gui thanh cong, hoac thong diep loi de UI hien.
  Future<String?> send({
    required MessageThreadKind kind,
    required String id,
    String? text,
    String? stickerAsset,
  }) async {
    final repository = _ref.read(communityRepositoryProvider);
    try {
      switch (kind) {
        case MessageThreadKind.group:
          await repository.sendGroupMessage(
            id,
            text: text,
            stickerAsset: stickerAsset,
          );
        case MessageThreadKind.post:
          await repository.sendPostComment(
            id,
            text: text,
            stickerAsset: stickerAsset,
          );
          // So binh luan vua tang, buoc dong thoi gian ve lai the bai dang.
          _ref.invalidate(feedProvider);
      }
      return null;
    } on Failure catch (failure) {
      return failure.message;
    }
  }
}

final messageSenderProvider = Provider<MessageSender>(MessageSender.new);

/// Danh sach nhom co the tham gia.
final joinableGroupsProvider = FutureProvider<List<StudyGroupSummary>>((ref) {
  return ref.watch(communityRepositoryProvider).getJoinableGroups();
});

/// Tao / tham gia / roi nhom.
class GroupActions {
  const GroupActions(this._ref);

  final Ref _ref;

  Future<String?> create(String name) =>
      _run(() => _repository.createGroup(name));

  Future<String?> join(String groupId) =>
      _run(() => _repository.joinGroup(groupId));

  Future<String?> leave() => _run(_repository.leaveGroup);

  CommunityRepository get _repository => _ref.read(communityRepositoryProvider);

  /// Tra `null` neu thanh cong, hoac thong diep loi.
  Future<String?> _run(Future<void> Function() action) async {
    try {
      await action();
      // Nhom doi thi ca tab Nhom va danh sach nhom deu phai tai lai.
      _ref.invalidate(studyGroupProvider);
      _ref.invalidate(joinableGroupsProvider);
      return null;
    } on Failure catch (failure) {
      return failure.message;
    }
  }
}

final groupActionsProvider = Provider<GroupActions>(GroupActions.new);
