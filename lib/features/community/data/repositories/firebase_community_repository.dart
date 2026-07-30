import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_labels.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/data/models/user_document.dart';
import '../../domain/entities/community_entities.dart';
import '../../domain/repositories/community_repository.dart';
import '../models/community_documents.dart';

/// Cộng đồng đọc từ Firestore: bài đăng, bảng xếp hạng, nhóm học tập.
class FirebaseCommunityRepository implements CommunityRepository {
  const FirebaseCommunityRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  /// Số người hiện trên bảng xếp hạng.
  static const _leaderboardSize = 20;

  String _requireUid() {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();
    return user.id;
  }

  @override
  Future<List<CommunityPost>> getFeed() async {
    final uid = _requireUid();

    try {
      final snapshot = await _firestore
          .collection(PostDocument.collection)
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      // Kiểm xem mình đã thích / đã lưu bài nào: đọc song song thay vì tuần tự.
      final flags = await Future.wait(
        snapshot.docs.map(
          (doc) async => (
            await doc.reference
                .collection(PostDocument.likesCollection)
                .doc(uid)
                .get(),
            await doc.reference
                .collection(PostDocument.bookmarksCollection)
                .doc(uid)
                .get(),
          ),
        ),
      );

      return [
        for (var i = 0; i < snapshot.docs.length; i++)
          PostDocument.toEntity(
            snapshot.docs[i].id,
            snapshot.docs[i].data(),
            isLiked: flags[i].$1.exists,
            isBookmarked: flags[i].$2.exists,
          ),
      ];
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<Leaderboard> getLeaderboard() async {
    final uid = _requireUid();

    try {
      final snapshot = await _firestore
          .collection(UserDocument.collection)
          .orderBy('experience', descending: true)
          .limit(_leaderboardSize)
          .get();

      final entries = <LeaderboardEntry>[];
      for (var i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final name = data['name'];
        entries.add(
          LeaderboardEntry(
            rank: i + 1,
            name: name is String && name.isNotEmpty ? name : 'Người học',
            avatarAsset: AppAssets.stickerHello,
            experience: switch (data['experience']) {
              final num value => value.toInt(),
              _ => 0,
            },
            isCurrentUser: doc.id == uid,
          ),
        );
      }

      // Hạng giải đấu suy từ XP của chính mình, không lưu riêng để hai chỗ khỏi
      // lệch nhau.
      final myExperience = entries
          .where((entry) => entry.isCurrentUser)
          .map((entry) => entry.experience)
          .firstOrNull;

      return Leaderboard(
        currentRank: ForestRank.fromExperience(myExperience ?? 0),
        entries: entries,
        // Nửa trên bảng là vùng an toàn.
        safeZoneEndRank: (entries.length / 2).ceil(),
      );
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  /// Truy van moi thanh vien cua mot nhom.
  ///
  /// Thanh vien **chinh la** `users/{uid}.groupId`, khong co subcollection
  /// rieng: vao/roi nhom chi can ghi document cua chinh minh, nen khong phai mo
  /// quyen ghi vao document nhom cho moi nguoi.
  Query<Map<String, dynamic>> _membersOf(String groupId) => _firestore
      .collection(UserDocument.collection)
      .where('groupId', isEqualTo: groupId);

  @override
  Future<StudyGroup?> getStudyGroup() async {
    final uid = _requireUid();

    try {
      final userSnapshot = await _firestore
          .collection(UserDocument.collection)
          .doc(uid)
          .get();
      final groupId = userSnapshot.data()?['groupId'];
      if (groupId is! String || groupId.isEmpty) return null;

      final groupRef = _firestore
          .collection(GroupDocument.collection)
          .doc(groupId);

      // So thanh vien va XP nhom tinh bang aggregate ngay tren server: khong
      // tai toan bo ho so ve may, va khong co con so luu san de lech.
      final (groupSnapshot, stats) = await (
        groupRef.get(),
        _membersOf(groupId).aggregate(count(), sum('experience')).get(),
      ).wait;

      final data = groupSnapshot.data();
      if (data == null) return null;

      return GroupDocument.toEntity(
        groupId,
        data,
        memberCount: stats.count ?? 0,
        totalExperience: (stats.getSum('experience') ?? 0).toInt(),
        isLeader: data['leaderId'] == uid,
      );
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<List<StudyGroupSummary>> getJoinableGroups() async {
    _requireUid();

    try {
      final snapshot = await _firestore
          .collection(GroupDocument.collection)
          .limit(30)
          .get();

      final counts = await Future.wait(
        snapshot.docs.map((doc) => _membersOf(doc.id).count().get()),
      );

      return [
        for (var i = 0; i < snapshot.docs.length; i++)
          StudyGroupSummary(
            id: snapshot.docs[i].id,
            name: readDocString(
              snapshot.docs[i].data()['name'],
              fallback: snapshot.docs[i].id,
            ),
            leaderName: readDocString(
              snapshot.docs[i].data()['leaderName'],
              fallback: 'Chua ro',
            ),
            memberCount: counts[i].count ?? 0,
          ),
      ];
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> createGroup(String name) async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure('Ten nhom khong duoc de trong.');
    }

    try {
      final groupRef = _firestore.collection(GroupDocument.collection).doc();

      final batch = _firestore.batch();
      batch.set(groupRef, {
        'name': trimmed,
        // `leaderId` phai la uid cua minh: rules chan viec tao nhom roi gan
        // truong nhom cho nguoi khac.
        'leaderId': user.id,
        'leaderName': user.greetingName,
        'daysRemaining': GroupDocument.defaultSeasonDays,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(
        _firestore.collection(UserDocument.collection).doc(user.id),
        {'groupId': groupRef.id, 'groupName': trimmed},
        SetOptions(merge: true),
      );
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> joinGroup(String groupId) async {
    final uid = _requireUid();

    try {
      final groupSnapshot = await _firestore
          .collection(GroupDocument.collection)
          .doc(groupId)
          .get();
      final data = groupSnapshot.data();
      if (data == null) {
        throw const NotFoundFailure('Nhom nay khong con ton tai.');
      }

      await _firestore.collection(UserDocument.collection).doc(uid).set({
        'groupId': groupId,
        'groupName': readDocString(data['name'], fallback: groupId),
      }, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<void> leaveGroup() async {
    final uid = _requireUid();

    try {
      // Xoa field thay vi ghi chuoi rong, de truy van where('groupId', ==)
      // khong bao gio khop document nay nua.
      await _firestore.collection(UserDocument.collection).doc(uid).update({
        'groupId': FieldValue.delete(),
        'groupName': FieldValue.delete(),
      });
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  // --- Chat nhom & binh luan -------------------------------------------

  @override
  Stream<List<ChatMessage>> watchGroupMessages(String groupId) =>
      _watchMessages(_groupMessages(groupId));

  @override
  Future<void> sendGroupMessage(
    String groupId, {
    String? text,
    String? stickerAsset,
  }) => _sendMessage(
    _groupMessages(groupId),
    text: text,
    stickerAsset: stickerAsset,
  );

  @override
  Stream<List<ChatMessage>> watchPostComments(String postId) => _watchMessages(
    _firestore
        .collection(PostDocument.collection)
        .doc(postId)
        .collection(MessageDocument.commentsCollection),
  );

  @override
  Future<void> sendPostComment(
    String postId, {
    String? text,
    String? stickerAsset,
  }) async {
    final postRef = _firestore.collection(PostDocument.collection).doc(postId);
    await _sendMessage(
      postRef.collection(MessageDocument.commentsCollection),
      text: text,
      stickerAsset: stickerAsset,
      // So binh luan hien tren the bai dang, phai tang cung luc.
      alsoWrite: (batch) => batch.set(postRef, {
        'commentCount': FieldValue.increment(1),
      }, SetOptions(merge: true)),
    );
  }

  CollectionReference<Map<String, dynamic>> _groupMessages(String groupId) =>
      _firestore
          .collection(GroupDocument.collection)
          .doc(groupId)
          .collection(GroupDocument.messagesCollection);

  Stream<List<ChatMessage>> _watchMessages(
    CollectionReference<Map<String, dynamic>> collection,
  ) {
    final uid = _authRepository.currentUser?.id ?? '';
    return collection
        .orderBy('createdAt')
        .limit(200)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => MessageDocument.toEntity(
                  doc.id,
                  doc.data(),
                  currentUid: uid,
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> _sendMessage(
    CollectionReference<Map<String, dynamic>> collection, {
    String? text,
    String? stickerAsset,
    void Function(WriteBatch batch)? alsoWrite,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    final hasText = text != null && text.trim().isNotEmpty;
    final hasSticker = stickerAsset != null && stickerAsset.isNotEmpty;
    if (!hasText && !hasSticker) {
      throw const ValidationFailure('Chua co noi dung de gui.');
    }

    try {
      final batch = _firestore.batch();
      batch.set(
        collection.doc(),
        MessageDocument.toMap(
          authorId: user.id,
          authorName: user.greetingName,
          text: text,
          stickerAsset: stickerAsset,
        ),
      );
      alsoWrite?.call(batch);
      await batch.commit();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  @override
  Future<CommunityPost> setLiked(String postId, {required bool isLiked}) =>
      _setFlag(
        postId,
        subcollection: PostDocument.likesCollection,
        counterField: 'likeCount',
        shouldSet: isLiked,
      );

  @override
  Future<CommunityPost> setBookmarked(
    String postId, {
    required bool isBookmarked,
  }) => _setFlag(
    postId,
    subcollection: PostDocument.bookmarksCollection,
    counterField: 'bookmarkCount',
    shouldSet: isBookmarked,
  );

  @override
  Future<void> createPost({
    required SharedWord word,
    required String detectedLabel,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) throw const UnauthorizedFailure();

    try {
      final batch = _firestore.batch();

      batch.set(_firestore.collection(PostDocument.collection).doc(), {
        // `authorId` phải đúng uid của mình: rules chặn việc mạo danh người khác.
        'authorId': user.id,
        'authorName': user.greetingName,
        'detectedLabel': detectedLabel,
        'sharedWord': {
          'english': word.english,
          'vietnamese': word.vietnamese,
          'phonetic': word.phonetic,
        },
        'likeCount': 0,
        'commentCount': 0,
        'bookmarkCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Số bài đăng hiện ở trang cá nhân, phải tăng cùng lúc để hai chỗ khỏi
      // lệch nhau.
      batch.set(
        _firestore.collection(UserDocument.collection).doc(user.id),
        {'postCount': FieldValue.increment(1)},
        SetOptions(merge: true),
      );

      await batch.commit();
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  /// Đặt một cờ dạng subcollection (thích, lưu bài) và cập nhật số đếm.
  ///
  /// Nhận trạng thái **mong muốn** thay vì đảo trạng thái hiện tại: bấm nhanh
  /// hai lần sẽ không làm số đếm lệch, vì lần nào cũng ghi về đúng một đích.
  Future<CommunityPost> _setFlag(
    String postId, {
    required String subcollection,
    required String counterField,
    required bool shouldSet,
  }) async {
    final uid = _requireUid();

    try {
      final postRef = _firestore
          .collection(PostDocument.collection)
          .doc(postId);
      final flagRef = postRef.collection(subcollection).doc(uid);

      final wasSet = (await flagRef.get()).exists;

      // Đã ở đúng trạng thái thì không ghi gì, chỉ đọc lại bài đăng.
      if (wasSet != shouldSet) {
        final batch = _firestore.batch();
        if (shouldSet) {
          batch.set(flagRef, {'createdAt': FieldValue.serverTimestamp()});
        } else {
          batch.delete(flagRef);
        }
        batch.set(postRef, {
          counterField: FieldValue.increment(shouldSet ? 1 : -1),
        }, SetOptions(merge: true));
        await batch.commit();
      }

      final updated = await postRef.get();
      final data = updated.data();
      if (data == null) throw const NotFoundFailure('Bài đăng không còn nữa.');

      final (likeSnapshot, bookmarkSnapshot) = await (
        postRef.collection(PostDocument.likesCollection).doc(uid).get(),
        postRef.collection(PostDocument.bookmarksCollection).doc(uid).get(),
      ).wait;

      return PostDocument.toEntity(
        postId,
        data,
        isLiked: likeSnapshot.exists,
        isBookmarked: bookmarkSnapshot.exists,
      );
    } on FirebaseException catch (error) {
      throw _toFailure(error);
    }
  }

  Failure _toFailure(FirebaseException error) {
    return switch (error.code) {
      'permission-denied' => const UnauthorizedFailure(
        'Không có quyền truy cập dữ liệu cộng đồng.',
      ),
      'unavailable' => const NetworkFailure(),
      'failed-precondition' => const ServerFailure(
        'Firestore cần tạo index cho truy vấn này. '
        'Xem link trong log để tạo bằng một cú bấm.',
      ),
      _ => ServerFailure(error.message ?? 'Không tải được dữ liệu cộng đồng.'),
    };
  }
}
