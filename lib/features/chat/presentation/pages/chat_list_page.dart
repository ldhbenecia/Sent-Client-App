import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../social/domain/models/chat_room.dart';
import '../../../social/presentation/providers/chat_list_provider.dart';
import '../../../social/presentation/widgets/social_tiles.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final roomsAsync = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.chatListTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: colors.textPrimary,
        backgroundColor: colors.card,
        onRefresh: () => ref.read(chatListProvider.notifier).refresh(),
        child: roomsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              color: colors.textMuted,
              strokeWidth: 1.5,
            ),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    color: colors.textDisabled, size: 40),
                const SizedBox(height: 12),
                Text(
                  e.toString().replaceAll('Exception: ', ''),
                  style: TextStyle(color: colors.textMuted, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      ref.read(chatListProvider.notifier).refresh(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (rooms) {
            if (rooms.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 52, color: colors.textDisabled),
                        const SizedBox(height: 16),
                        Text(
                          l10n.chatListEmpty,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.chatListEmptySubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textDisabled,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rooms.length,
              separatorBuilder: (_, index) => Divider(
                height: 0.5,
                indent: 72,
                color: colors.border,
              ),
              itemBuilder: (context, index) =>
                  _ChatRoomTile(room: rooms[index]),
            );
          },
        ),
      ),
    );
  }
}

// ── 채팅방 타일 ────────────────────────────────────────────────────
class _ChatRoomTile extends StatelessWidget {
  const _ChatRoomTile({required this.room});
  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    DateTime? msgDt;
    bool isToday = false;
    if (room.lastMessageTimestamp != null) {
      msgDt = DateTime.fromMillisecondsSinceEpoch(room.lastMessageTimestamp!);
      final now = DateTime.now();
      isToday = msgDt.year == now.year &&
          msgDt.month == now.month &&
          msgDt.day == now.day;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          '/social/chat',
          extra: {
            'opponentId': room.opponentId,
            'friendName': room.opponentName,
          },
        ),
        splashColor: Colors.white.withValues(alpha: 0.04),
        highlightColor: Colors.white.withValues(alpha: 0.02),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SocialAvatar(
                imageUrl: room.opponentProfileImageUrl,
                name: room.opponentName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.opponentName,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (room.lastMessage != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        room.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (msgDt != null) ...[
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isToday)
                      Text(
                        '${msgDt.month}/${msgDt.day}',
                        style: TextStyle(
                          color: colors.textDisabled,
                          fontSize: 10,
                        ),
                      ),
                    Text(
                      '${msgDt.hour.toString().padLeft(2, '0')}:${msgDt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: colors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
