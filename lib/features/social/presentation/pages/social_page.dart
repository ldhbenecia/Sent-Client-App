import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../../shared/widgets/app_nav_menu.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../providers/friend_provider.dart';
import '../../domain/models/friend.dart';
import '../widgets/social_tiles.dart';
import '../widgets/add_friend_sheet.dart';

class SocialPage extends ConsumerWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final friendsAsync = ref.watch(friendsProvider);
    final receivedAsync = ref.watch(pendingRequestsProvider);
    final sentAsync = ref.watch(sentRequestsProvider);
    final receivedCount = receivedAsync.valueOrNull?.length ?? 0;
    final sentCount = sentAsync.valueOrNull?.length ?? 0;
    final hasAnyRequests = receivedCount > 0 || sentCount > 0;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Text('SENT'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded,
                color: colors.textMuted, size: 22),
            onPressed: () => _showAddFriendSheet(context, ref),
          ),
          IconButton(
            icon: Icon(Icons.menu_rounded,
                color: colors.textMuted, size: 22),
            onPressed: () => showAppNavMenu(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: colors.textPrimary,
        backgroundColor: colors.card,
        onRefresh: () async {
          await Future.wait([
            ref.read(friendsProvider.notifier).refresh(),
            ref.read(pendingRequestsProvider.notifier).refresh(),
            ref.read(sentRequestsProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── 내 코드 카드 ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: _MyCodeCard(),
            ),

            // ── 친구 요청 행 (보낸/받은 중 하나라도 있으면 표시) ───
            if (hasAnyRequests)
              SliverToBoxAdapter(
                child: _RequestsRow(
                  receivedCount: receivedCount,
                  sentCount: sentCount,
                  onTap: () => context.push('/social/requests'),
                ),
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
                    label: '${l10n.friendsSection} ${friends.length}',
                    child: Column(
                      children: friends
                          .map((f) => FriendTile(
                                friend: f,
                                onTap: () => context.push(
                                  '/social/chat',
                                  extra: {
                                    'opponentId': f.friendId,
                                    'friendName': f.friendDisplayName,
                                    'opponentProfileImageUrl': f.friendProfileImageUrl,
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
              loading: () => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colors.textMuted,
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
                      Icon(Icons.error_outline_rounded,
                          color: colors.textDisabled, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: TextStyle(
                            color: colors.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () =>
                            ref.read(friendsProvider.notifier).refresh(),
                        child: Text(l10n.retry),
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.friendDeleteTitle,
            style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        content: Text(
          l10n.friendDeleteMessage(friend.friendDisplayName),
          style:
              TextStyle(color: colors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel,
                style: TextStyle(color: colors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete,
                style: TextStyle(color: colors.destructiveRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(friendsProvider.notifier).delete(friend.id);
    } catch (e) {
      if (context.mounted) {
        showTopToast(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showAddFriendSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFriendSheet(ref: ref),
    );
  }
}

// ── 친구 요청 배지 행 ─────────────────────────────────────────────────
class _RequestsRow extends StatelessWidget {
  const _RequestsRow({
    required this.receivedCount,
    required this.sentCount,
    required this.onTap,
  });

  final int receivedCount;
  final int sentCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasReceived = receivedCount > 0;

    final label = switch ((receivedCount, sentCount)) {
      (final r, _) when r > 0 => '받은 친구 요청 $r건',
      (_, final s) when s > 0 => '보낸 친구 요청 $s건',
      _ => '친구 요청',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasReceived
                ? const Color(0xFFFF3B30).withValues(alpha: 0.10)
                : colors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasReceived
                  ? const Color(0xFFFF3B30).withValues(alpha: 0.25)
                  : colors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              if (hasReceived)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 내 유저코드 카드 ──────────────────────────────────────────────────
class _MyCodeCard extends ConsumerStatefulWidget {
  const _MyCodeCard();

  @override
  ConsumerState<_MyCodeCard> createState() => _MyCodeCardState();
}

class _MyCodeCardState extends ConsumerState<_MyCodeCard> {
  bool _copied = false;

  Future<void> _onCopy(String code, AppLocalizations l10n) async {
    if (_copied) return;
    await Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: GestureDetector(
            onTap: () => _onCopy(profile.userCode, l10n),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.myCode,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.userCode,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      key: ValueKey(_copied),
                      size: 18,
                      color: _copied ? colors.textPrimary : colors.textDisabled,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}
