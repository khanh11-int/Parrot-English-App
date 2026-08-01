/// Một tin nhắn trong chat nhóm, hoặc một bình luận dưới bài đăng.
///
/// Hai chỗ dùng chung một kiểu vì nội dung giống nhau: người gửi, chữ hoặc
/// sticker, thời điểm.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.timeAgo,
    this.text,
    this.stickerAsset,
    this.isMine = false,
  });

  final String id;
  final String authorId;
  final String authorName;

  /// Chuỗi thời gian đã định dạng, ví dụ "5 phút trước".
  final String timeAgo;

  /// Nội dung chữ; `null` khi đây là tin nhắn sticker.
  final String? text;

  /// Đường dẫn asset sticker; `null` khi đây là tin nhắn chữ.
  final String? stickerAsset;

  /// Tin của chính mình → hiện lệch sang phải, màu khác.
  final bool isMine;

  bool get isSticker => stickerAsset != null && stickerAsset!.isNotEmpty;
}
