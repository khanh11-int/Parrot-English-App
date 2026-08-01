import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/message_composer.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/community_providers.dart';

/// Chat của một nhóm học tập.
class MessageThreadPage extends ConsumerWidget {
  const MessageThreadPage({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.threadId,
  });

  final String title;
  final String emptyMessage;
  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messageThreadProvider((id: threadId)));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: switch (messagesAsync) {
                AsyncValue(hasError: true) => AppErrorView(
                  message: 'Không tải được tin nhắn.',
                  onRetry: () =>
                      ref.invalidate(messageThreadProvider((id: threadId))),
                ),
                AsyncValue(:final valueOrNull?) =>
                  valueOrNull.isEmpty
                      ? EmptyState(
                          message: emptyMessage,
                          mascotAsset: AppAssets.stickerHello,
                        )
                      : _MessageList(messages: valueOrNull),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
            MessageComposer(
              onSend: ({String? text, String? stickerAsset}) => ref
                  .read(messageSenderProvider)
                  .send(id: threadId, text: text, stickerAsset: stickerAsset),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // Đảo ngược để tin mới nhất ở dưới và danh sách tự dính đáy khi có tin
      // mới — không phải tự gọi cuộn xuống.
      reverse: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return MessageBubble(
          authorName: message.authorName,
          timeAgo: message.timeAgo,
          isMine: message.isMine,
          text: message.text,
          stickerAsset: message.stickerAsset,
        );
      },
    );
  }
}
