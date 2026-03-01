import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../domain/models/chat_message.dart';
import '../providers/chat_provider.dart';

// ══════════════════════════════════════════════════════════════════
// ChatPage
// ══════════════════════════════════════════════════════════════════
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({
    super.key,
    required this.opponentId,
    required this.friendName,
  });

  final String opponentId;
  final String friendName;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // reverse: true → maxScrollExtent = 위쪽(오래된 메시지) 끝
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(chatNotifierProvider(widget.opponentId).notifier)
          .loadMore();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final content = _textController.text.trim();
    if (content.isEmpty) return;
    ref.read(chatNotifierProvider(widget.opponentId).notifier).send(content);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chatAsync = ref.watch(chatNotifierProvider(widget.opponentId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: colors.textMuted,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.friendName,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: colors.textMuted,
                  strokeWidth: 1.5,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (chatState) => _MessageList(
                chatState: chatState,
                scrollController: _scrollController,
              ),
            ),
          ),
          // STOMP 연결 상태 배너
          if (chatAsync.hasValue && !chatAsync.requireValue.isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: colors.card,
              child: Text(
                AppLocalizations.of(context)!.connectingToServer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textDisabled,
                  fontSize: 12,
                ),
              ),
            ),
          _InputBar(
            controller: _textController,
            onSend: _send,
            enabled: chatAsync.hasValue && chatAsync.requireValue.isConnected,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 메시지 목록
// ══════════════════════════════════════════════════════════════════
class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.chatState,
    required this.scrollController,
  });

  final ChatState chatState;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final messages = chatState.messages;

    if (messages.isEmpty && !chatState.isLoadingMore) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.chatEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textDisabled,
            fontSize: 14,
            height: 1.7,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length + (chatState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // 위쪽 끝(가장 오래된 메시지 위) — 로딩 인디케이터
        if (index == messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: colors.textMuted,
                strokeWidth: 1.5,
              ),
            ),
          );
        }
        final message = messages[index];
        final isMe = chatState.myUserId != null &&
            message.senderId == chatState.myUserId;
        return _MessageBubble(message: message, isMe: isMe);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 메시지 버블
// ══════════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time =
        DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isMe
            ? [
                Text(
                  timeStr,
                  style: TextStyle(
                    color: colors.textDisabled,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                _Bubble(content: message.content, isMe: true),
              ]
            : [
                _Bubble(content: message.content, isMe: false),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    color: colors.textDisabled,
                    fontSize: 10,
                  ),
                ),
              ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.content, required this.isMe});

  final String content;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary600 : colors.card,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        border: isMe
            ? null
            : Border.all(color: colors.border, width: 0.5),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 입력창
// ══════════════════════════════════════════════════════════════════
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomPadding),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                style: TextStyle(
                  color: enabled
                      ? colors.textPrimary
                      : colors.textDisabled,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: enabled ? AppLocalizations.of(context)!.messageHint : AppLocalizations.of(context)!.connectingHint,
                  hintStyle: TextStyle(
                    color: colors.textPlaceholder,
                    fontSize: 15,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: InputBorder.none,
                ),
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => enabled ? onSend() : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: enabled
                    ? AppColors.primary600
                    : colors.textDisabled,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: colors.textPrimary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
