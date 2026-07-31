import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'sticker_picker.dart';

/// Ô soạn tin nhắn: nhập chữ, chọn sticker, gửi.
///
/// Dùng chung cho chat nhóm và bình luận bài đăng — hai chỗ có cùng nhu cầu nên
/// không cần hai widget riêng.
class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSend,
    this.hint = 'Nhập tin nhắn...',
  });

  /// Gửi tin. Đúng một trong hai tham số có giá trị.
  ///
  /// Trả về thông điệp lỗi, hoặc `null` nếu gửi thành công.
  final Future<String?> Function({String? text, String? stickerAsset}) onSend;

  final String hint;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send({String? text, String? stickerAsset}) async {
    if (_isSending) return;
    setState(() => _isSending = true);

    // Xoá ô nhập ngay để người dùng gõ tiếp được, nhưng giữ lại bản sao: gửi
    // thất bại thì trả nội dung về chứ không để họ mất công gõ lại.
    final draft = _controller.text;
    if (text != null) {
      // Kết thúc vùng đang soạn TRƯỚC khi xoá. Bàn phím tiếng Việt (Telex/VNI)
      // gần như luôn có vùng soạn đang mở; xoá thẳng thì phía hệ điều hành vẫn
      // giữ vùng soạn trỏ vào chuỗi cũ, lần cập nhật sau nó gửi về một khoảng
      // vượt ra ngoài chuỗi mới và Flutter bắn assert
      // "Range end N is out of text of length M".
      _controller.clearComposing();
      _controller.clear();
    }

    final error = await widget.onSend(text: text, stickerAsset: stickerAsset);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (error == null) return;
    // Chỉ trả nháp về khi ô vẫn đang trống. Gửi mất một lúc, người dùng có thể
    // đã gõ tin tiếp theo — ghi đè lên đó là xoá mất chữ họ vừa gõ.
    if (text != null && _controller.text.isEmpty) {
      _controller.clearComposing();
      _controller.text = draft;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
          duration: AppDurations.snackBar,
        ),
      );
  }

  Future<void> _pickSticker() async {
    final sticker = await showStickerPicker(context);
    if (sticker == null) return;
    await _send(stickerAsset: sticker);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgBase,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        // Cộng vùng an toàn dưới để ô nhập không bị thanh hệ thống che.
        bottom: AppSpacing.sm + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _isSending ? null : _pickSticker,
            icon: const Icon(Icons.emoji_emotions_outlined),
            color: AppColors.primary,
            tooltip: 'Gửi sticker',
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              style: AppTextStyles.body,
              onSubmitted: (value) => _send(text: value),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textDisabled,
                ),
                filled: true,
                fillColor: AppColors.neutral,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.chipBorder,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _SendButton(
            isSending: _isSending,
            onPressed: () => _send(text: _controller.text),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.isSending, required this.onPressed});

  final bool isSending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: isSending
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : IconButton.filled(
              onPressed: onPressed,
              icon: const Icon(Icons.send_rounded, size: 20),
              tooltip: 'Gửi',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
    );
  }
}

/// Một bong bóng tin nhắn hoặc bình luận.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.authorName,
    required this.timeAgo,
    required this.isMine,
    this.text,
    this.stickerAsset,
  });

  final String authorName;
  final String timeAgo;
  final bool isMine;
  final String? text;
  final String? stickerAsset;

  @override
  Widget build(BuildContext context) {
    final sticker = stickerAsset;
    final isSticker = sticker != null && sticker.isNotEmpty;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        // Kẹp bề rộng để tin dài không chạy hết ngang màn hình, khó đọc.
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Tin của mình thì khỏi nhắc tên, người đọc biết là mình.
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 2),
                child: Text(authorName, style: AppTextStyles.caption),
              ),
            if (isSticker)
              Image.asset(sticker, height: 88)
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isMine ? AppColors.primary : AppColors.neutral,
                  borderRadius: AppRadius.cardBorder,
                ),
                child: Text(
                  text ?? '',
                  style: AppTextStyles.body.copyWith(
                    color: isMine
                        ? AppColors.textOnPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                top: 2,
              ),
              child: Text(timeAgo, style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }
}
