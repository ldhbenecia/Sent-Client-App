import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../providers/friend_provider.dart';
import '../../domain/models/friend.dart';
import '../widgets/social_tiles.dart';
import '../widgets/add_friend_sheet.dart';

class FriendRequestsPage extends ConsumerWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final receivedAsync = ref.watch(pendingRequestsProvider);
    final sentAsync = ref.watch(sentRequestsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(l10n.request),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt_1_rounded,
                color: colors.textMuted, size: 22),
            onPressed: () => _showAddFriendSheet(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: colors.textPrimary,
        backgroundColor: colors.card,
        onRefresh: () async {
          await Future.wait([
            ref.read(pendingRequestsProvider.notifier).refresh(),
            ref.read(sentRequestsProvider.notifier).refresh(),
          ]);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // ── 받은 요청 ─────────────────────────────────────────
            SocialSection(
              label: l10n.friendRequestsSection,
              child: receivedAsync.when(
                data: (requests) {
                  if (requests.isEmpty) {
                    return _EmptyState(text: l10n.noReceivedRequests);
                  }
                  return Column(
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
                  );
                },
                loading: () => const _LoadingState(),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ),

            // ── 보낸 요청 ─────────────────────────────────────────
            SocialSection(
              label: l10n.sentRequestsSection,
              child: sentAsync.when(
                data: (sentList) {
                  if (sentList.isEmpty) {
                    return _EmptyState(text: l10n.sentRequestsEmpty);
                  }
                  return Column(
                    children: sentList
                        .map((r) => SentFriendRequestTile(
                              request: r,
                              onCancel:
                                  r.status == SentRequestStatus.pending
                                      ? () => ref
                                          .read(sentRequestsProvider.notifier)
                                          .cancel(r.id)
                                      : null,
                            ))
                        .toList(),
                  );
                },
                loading: () => const _LoadingState(),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: TextStyle(color: colors.textDisabled, fontSize: 13),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: CircularProgressIndicator(
          color: colors.textMuted,
          strokeWidth: 1.5,
        ),
      ),
    );
  }
}
