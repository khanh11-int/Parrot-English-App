import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/user_data_revision.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/firebase_community_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/leaderboard.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/entities/study_group_summary.dart';
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

final leaderboardProvider = FutureProvider<Leaderboard>((ref) {
  // Đổi người đăng nhập thì tải lại: hàng "của tôi" trên bảng phải đúng người.
  ref.watch(currentUserProvider);
  // Học xong thì XP đổi, đổi tên thì `users/{uid}.name` đổi — cả hai đều là dữ
  // liệu bảng này hiển thị.
  ref.watch(userDataRevisionProvider);
  return ref.watch(communityRepositoryProvider).getLeaderboard();
});

final studyGroupProvider = FutureProvider<StudyGroup?>((ref) {
  ref.watch(currentUserProvider);
  return ref.watch(communityRepositoryProvider).getStudyGroup();
});

/// Khoa cua mot luong tin nhan. Ban nay chi co chat nhom.
typedef MessageThreadKey = ({String id});

/// Tin nhan cua mot luong, cap nhat lien tuc.
///
/// Dung `StreamProvider` chu khong phai `FutureProvider`: chat phai thay tin
/// nguoi khac gui ngay, khong phai keo de lam moi.
final messageThreadProvider =
    StreamProvider.family<List<ChatMessage>, MessageThreadKey>((ref, key) {
      return ref.watch(communityRepositoryProvider).watchGroupMessages(key.id);
    });

/// Gui tin nhan / binh luan.
class MessageSender {
  const MessageSender(this._ref);

  final Ref _ref;

  /// Tra `null` neu gui thanh cong, hoac thong diep loi de UI hien.
  Future<String?> send({
    required String id,
    String? text,
    String? stickerAsset,
  }) async {
    try {
      await _ref
          .read(communityRepositoryProvider)
          .sendGroupMessage(id, text: text, stickerAsset: stickerAsset);
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
