import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_nav_menu.dart';
import '../providers/friend_provider.dart';
import '../../data/repositories/friend_repository.dart';
import '../../domain/models/friend.dart';

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
            onPressed: () => _showAddFriendDialog(context, ref),
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
                  child: _Section(
                    label: '받은 친구 요청 ${requests.length}',
                    child: Column(
                      children: requests
                          .map((r) => _RequestTile(
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
                    child: _EmptyFriends(),
                  );
                }
                return SliverToBoxAdapter(
                  child: _Section(
                    label: '친구 ${friends.length}',
                    child: Column(
                      children:
                          friends.map((f) => _FriendTile(friend: f)).toList(),
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
                      Text(e.toString(),
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 14)),
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

  Future<void> _showAddFriendDialog(
      BuildContext context, WidgetRef ref) async {
    final receiverId = await showDialog<String>(
      context: context,
      builder: (_) => const _AddFriendDialog(),
    );
    if (receiverId == null || receiverId.isEmpty) return;
    try {
      await ref.read(friendRepositoryProvider).addFriend(receiverId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('친구 요청을 보냈습니다.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

// ── 친구 추가 다이얼로그 (StatefulWidget — controller lifecycle 관리) ──
class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        '친구 추가',
        style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600),
      ),
      content: TextField(
        controller: _controller,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: '친구 ID를 입력해주세요',
          hintStyle:
              const TextStyle(color: AppColors.textDisabled, fontSize: 14),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.textMuted.withOpacity(0.5)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        autofocus: true,
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('요청 보내기'),
        ),
      ],
    );
  }
}

// ── 섹션 래퍼 ─────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── 친구 타일 ─────────────────────────────────────────────────────
class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Avatar(
            imageUrl: friend.friendProfileImageUrl,
            name: friend.friendDisplayName,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.friendDisplayName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 요청 타일 ─────────────────────────────────────────────────────
class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _Avatar(
            imageUrl: request.friendProfileImageUrl,
            name: request.friendDisplayName,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              request.friendDisplayName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAccept,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('수락',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReject,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text('거절',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 아바타 ────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.imageUrl});
  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _Initials(name),
            )
          : _Initials(name),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────────
class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline_rounded,
            size: 52, color: AppColors.textDisabled),
        SizedBox(height: 16),
        Text(
          '친구가 없습니다',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '오른쪽 위 버튼으로\n첫 번째 친구를 추가해보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textDisabled,
            fontSize: 13,
            letterSpacing: -0.1,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
