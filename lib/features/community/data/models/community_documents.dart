import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/community_entities.dart';

/// Ánh xạ document Firestore `posts/{postId}`.
abstract final class PostDocument {
  static const collection = 'posts';

  /// Thích và lưu bài là **subcollection**, mỗi người một document id = uid.
  ///
  /// Không dùng mảng `likedBy`: mảng vỡ khi bài có hàng nghìn lượt thích, và
  /// hai người bấm cùng lúc sẽ ghi đè nhau.
  static const likesCollection = 'likes';
  static const bookmarksCollection = 'bookmarks';

  static CommunityPost toEntity(
    String id,
    Map<String, dynamic> map, {
    required bool isLiked,
    bool isBookmarked = false,
  }) {
    final word = map['sharedWord'];
    final wordMap = word is Map<String, dynamic>
        ? word
        : const <String, dynamic>{};

    return CommunityPost(
      id: id,
      authorName: readDocString(map['authorName'], fallback: 'Người học'),
      // Chưa có Storage cho ảnh đại diện thật nên dùng sticker trong app.
      authorAvatarAsset: AppAssets.stickerHello,
      timeAgo: timeAgo(map['createdAt']),
      sharedWord: SharedWord(
        english: readDocString(wordMap['english']),
        vietnamese: readDocString(wordMap['vietnamese']),
        phonetic: readDocString(wordMap['phonetic']),
      ),
      detectedLabel: readDocString(map['detectedLabel']),
      likeCount: readDocInt(map['likeCount']),
      commentCount: readDocInt(map['commentCount']),
      bookmarkCount: readDocInt(map['bookmarkCount']),
      isLiked: isLiked,
      isBookmarked: isBookmarked,
    );
  }

  /// Đổi `Timestamp` thành chuỗi kiểu "5 phút trước".
  ///
  /// Tính ở client vì đây là dữ liệu hiển thị thuần; server chỉ cần lưu mốc
  /// thời gian chuẩn.
  static String timeAgo(Object? value) {
    if (value is! Timestamp) return 'vừa xong';

    final difference = DateTime.now().difference(value.toDate());
    if (difference.inMinutes < 1) return 'vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    if (difference.inDays < 30) return '${difference.inDays} ngày trước';
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    }
    return '${(difference.inDays / 365).floor()} năm trước';
  }
}

/// Ánh xạ document Firestore `groups/{groupId}`.
abstract final class GroupDocument {
  static const collection = 'groups';
  static const messagesCollection = 'messages';

  /// Số ngày mặc định của một mùa, dùng cho nhóm mới tạo.
  static const defaultSeasonDays = 7;

  /// [memberCount] và [totalExperience] **không đọc từ document** mà do
  /// repository tính bằng aggregate trên `users`.
  ///
  /// Lý do: nếu lưu sẵn hai con số đó thì mỗi lần có người vào/rời nhóm đều
  /// phải cho họ ghi vào document nhóm — mở quyền đó ra là ai cũng sửa được XP
  /// của cả nhóm.
  static StudyGroup toEntity(
    String id,
    Map<String, dynamic> map, {
    required int memberCount,
    required int totalExperience,
    required bool isLeader,
  }) {
    return StudyGroup(
      id: id,
      name: readDocString(map['name'], fallback: 'Nhóm học tập'),
      memberCount: memberCount,
      leaderName: readDocString(map['leaderName'], fallback: 'Chưa rõ'),
      avatarAsset: AppAssets.stickerLove,
      totalExperience: totalExperience,
      daysRemaining: readDocInt(map['daysRemaining']),
      isLeader: isLeader,
    );
  }
}

/// Ánh xạ tin nhắn chat nhóm và bình luận bài đăng — cùng một hình dạng.
abstract final class MessageDocument {
  static const commentsCollection = 'comments';

  static ChatMessage toEntity(
    String id,
    Map<String, dynamic> map, {
    required String currentUid,
  }) {
    final authorId = readDocString(map['authorId']);
    final sticker = readDocString(map['stickerAsset']);
    final text = readDocString(map['text']);

    return ChatMessage(
      id: id,
      authorId: authorId,
      authorName: readDocString(map['authorName'], fallback: 'Người học'),
      timeAgo: PostDocument.timeAgo(map['createdAt']),
      text: text.isEmpty ? null : text,
      stickerAsset: sticker.isEmpty ? null : sticker,
      isMine: authorId == currentUid,
    );
  }

  static Map<String, dynamic> toMap({
    required String authorId,
    required String authorName,
    String? text,
    String? stickerAsset,
  }) => {
    'authorId': authorId,
    'authorName': authorName,
    if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
    if (stickerAsset != null && stickerAsset.isNotEmpty)
      'stickerAsset': stickerAsset,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

/// Đọc chuỗi từ document, trả [fallback] khi thiếu hoặc sai kiểu.
String readDocString(Object? value, {String fallback = ''}) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return fallback;
}

/// Đọc số nguyên từ document, trả 0 khi thiếu hoặc sai kiểu.
int readDocInt(Object? value) => value is num ? value.toInt() : 0;
