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
    this.opponentProfileImageUrl,
  });

  final String opponentId;
  final String friendName;
  final String? opponentProfileImageUrl;

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

  void _showOpponentProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OpponentProfileSheet(
        name: widget.friendName,
        profileImageUrl: widget.opponentProfileImageUrl,
      ),
    );
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
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showOpponentProfile,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ChatAvatar(
                imageUrl: widget.opponentProfileImageUrl,
                name: widget.friendName,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                widget.friendName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                  style: TextStyle(color: colors.textMuted, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (chatState) => _MessageList(
                chatState: chatState,
                scrollController: _scrollController,
                opponentProfileImageUrl: widget.opponentProfileImageUrl,
                opponentName: widget.friendName,
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
                style: TextStyle(color: colors.textDisabled, fontSize: 12),
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
// 리스트 아이템 타입
// ══════════════════════════════════════════════════════════════════
sealed class _ListItem {}

class _MessageItem extends _ListItem {
  _MessageItem(this.message);
  final ChatMessage message;
}

class _SeparatorItem extends _ListItem {
  _SeparatorItem(this.date);
  final DateTime date;
}

// ══════════════════════════════════════════════════════════════════
// 메시지 목록
// ══════════════════════════════════════════════════════════════════
class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.chatState,
    required this.scrollController,
    required this.opponentProfileImageUrl,
    required this.opponentName,
  });

  final ChatState chatState;
  final ScrollController scrollController;
  final String? opponentProfileImageUrl;
  final String opponentName;

  DateTime _toDay(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime(dt.year, dt.month, dt.day);
  }

  // reverse:true 리스트 기준
  // index 0 = 가장 최신(하단), 날짜 구분자는 각 날의 최상단(= 해당 날의 가장 오래된 메시지 위)에 삽입
  List<_ListItem> _buildItems(List<ChatMessage> messages) {
    if (messages.isEmpty) return [];
    final items = <_ListItem>[];
    for (int i = 0; i < messages.length; i++) {
      items.add(_MessageItem(messages[i]));
      final curDay = _toDay(messages[i].timestamp);
      final isLast = i == messages.length - 1;
      final nextDay = isLast ? null : _toDay(messages[i + 1].timestamp);
      if (isLast || curDay != nextDay) {
        items.add(_SeparatorItem(curDay));
      }
    }
    return items;
  }

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

    final items = _buildItems(messages);
    final extraCount = chatState.isLoadingMore ? 1 : 0;

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      itemCount: items.length + extraCount,
      itemBuilder: (context, index) {
        // 로딩 인디케이터 (가장 위)
        if (index == items.length) {
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

        final item = items[index];

        if (item is _SeparatorItem) {
          return _DateSeparator(date: item.date);
        }

        final msgItem = item as _MessageItem;
        final message = msgItem.message;
        final isMe = chatState.myUserId != null &&
            message.senderId == chatState.myUserId;

        // 아바타: 상대방 메시지 중 그룹 하단 첫 번째(가장 최신, 낮은 index)에만 표시
        final prevItem = index > 0 ? items[index - 1] : null;
        final showAvatar = !isMe &&
            (prevItem == null ||
                prevItem is _SeparatorItem ||
                (prevItem is _MessageItem &&
                    prevItem.message.senderId != message.senderId));

        // 그룹 상단 여백: 다음 아이템이 다른 발신자거나 구분자면 여백 추가
        final nextItem = index < items.length - 1 ? items[index + 1] : null;
        final isGroupTop = nextItem == null ||
            nextItem is _SeparatorItem ||
            (nextItem is _MessageItem &&
                nextItem.message.senderId != message.senderId);
        final bottomSpacing = isGroupTop ? 14.0 : 3.0;

        return _MessageBubble(
          message: message,
          isMe: isMe,
          showAvatar: showAvatar,
          opponentProfileImageUrl: opponentProfileImageUrl,
          opponentName: opponentName,
          bottomSpacing: bottomSpacing,
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 날짜 구분자
// ══════════════════════════════════════════════════════════════════
class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final label = l10n.chatDateLabel(date.year, date.month, date.day);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: colors.border, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(color: colors.textDisabled, fontSize: 12),
            ),
          ),
          Expanded(child: Divider(color: colors.border, thickness: 0.5)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 메시지 버블
// ══════════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.opponentProfileImageUrl,
    required this.opponentName,
    this.bottomSpacing = 3.0,
  });

  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final String? opponentProfileImageUrl;
  final String opponentName;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isMe
            ? [
                Text(
                  timeStr,
                  style: TextStyle(color: colors.textDisabled, fontSize: 10),
                ),
                const SizedBox(width: 4),
                _Bubble(content: message.content, isMe: true),
              ]
            : [
                // 아바타 자리 (36px 고정)
                SizedBox(
                  width: 36,
                  child: showAvatar
                      ? _ChatAvatar(
                          imageUrl: opponentProfileImageUrl,
                          name: opponentName,
                          size: 32,
                        )
                      : null,
                ),
                const SizedBox(width: 6),
                _Bubble(content: message.content, isMe: false),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(color: colors.textDisabled, fontSize: 10),
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
        maxWidth: MediaQuery.of(context).size.width * 0.62,
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
        border: isMe ? null : Border.all(color: colors.border, width: 0.5),
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
// 아바타 (AppBar + 버블 공용)
// ══════════════════════════════════════════════════════════════════
class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({
    required this.imageUrl,
    required this.name,
    required this.size,
  });

  final String? imageUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, st) => _Initial(name: name, size: size),
            )
          : _Initial(name: name, size: size),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: colors.textMuted,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 상대방 프로필 시트
// ══════════════════════════════════════════════════════════════════
class _OpponentProfileSheet extends StatelessWidget {
  const _OpponentProfileSheet({
    required this.name,
    required this.profileImageUrl,
  });

  final String name;
  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _ChatAvatar(imageUrl: profileImageUrl, name: name, size: 72),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: colors.border, height: 0.5),
            _SheetAction(
              icon: Icons.exit_to_app_rounded,
              label: l10n.leaveChatRoom,
              onTap: () {
                Navigator.pop(context);
                // TODO: leave chat room API
              },
            ),
            Divider(color: colors.border, height: 0.5, indent: 56),
            _SheetAction(
              icon: Icons.block_rounded,
              label: l10n.blockUser,
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.comingSoon)),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isDestructive ? Colors.redAccent : colors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
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
                  color: enabled ? colors.textPrimary : colors.textDisabled,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: enabled
                      ? AppLocalizations.of(context)!.messageHint
                      : AppLocalizations.of(context)!.connectingHint,
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
                color: enabled ? AppColors.primary600 : colors.textDisabled,
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
