import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_nav_menu.dart';
import '../providers/friend_provider.dart';
import '../../domain/models/friend.dart';
import '../widgets/social_tiles.dart';
import '../widgets/add_friend_sheet.dart';

class SocialPage extends ConsumerWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    final requestsAsync = ref.watch(pendingRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SENT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded,
                color: AppColors.textMuted, size: 22),
            onPressed: () => _showAddFriendSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.menu_rounded,
                color: AppColors.textMuted, size: 22),
            onPressed: () => showAppNavMenu(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.textPrimary,
        backgroundColor: AppColors.card,
        onRefresh: () async {
          await Future.wait([
            ref.read(friendsProvider.notifier).refresh(),
            ref.read(pendingRequestsProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── 받은 요청 섹션 ────────────────────────────────────
            requestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: SocialSection(
                    label: '받은 친구 요청 ${requests.length}',
                    child: Column(
                      children: requests
                          .map((r) => FriendRequestTile(
                                request: r,
                                onAccept: () => ref
                                    .read(pendingRequestsProvider.notifier)
                                    .accept(r.id),
                                onReject: () => ref
                                    .read(pendingRequestsProvider.notifier)
                                    .reject(r.id),
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // ── 친구 목록 섹션 ────────────────────────────────────
            friendsAsync.when(
              data: (friends) {
                if (friends.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyFriendsList(),
                  );
                }
                return SliverToBoxAdapter(
                  child: SocialSection(
                    label: '친구 ${friends.length}',
                    child: Column(
                      children: friends
                          .map((f) => FriendTile(
                                friend: f,
                                onTap: () => context.push(
                                  '/social/chat',
                                  extra: {
                                    'opponentId': f.friendId,
                                    'friendName': f.friendDisplayName,
                                  },
                                ),
                                onDelete: () =>
                                    _confirmDelete(context, ref, f),
                              ))
                          .toList(),
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.textMuted,
                    strokeWidth: 1.5,
                  ),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.textDisabled, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () =>
                            ref.read(friendsProvider.notifier).refresh(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Friend friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('친구 삭제',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        content: Text(
          '${friend.friendDisplayName}님을 친구 목록에서 삭제할까요?',
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제',
                style: TextStyle(color: AppColors.destructiveRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(friendsProvider.notifier).delete(friend.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _showAddFriendSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFriendSheet(ref: ref),
    );
  }
}
