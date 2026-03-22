import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/theme/app_color_theme.dart';
import '../../../../../shared/widgets/pressable_highlight.dart';
import '../../domain/models/friend.dart';

// ── 섹션 컨테이너 ──────────────────────────────────────────────────
class SocialSection extends StatelessWidget {
  const SocialSection({super.key, required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              label,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 0.5),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── 친구 타일 ─────────────────────────────────────────────────────
class FriendTile extends StatelessWidget {
  const FriendTile({
    super.key,
    required this.friend,
    required this.onDelete,
    this.onTap,
  });
  final Friend friend;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableHighlight(
        onTap: onTap,
        borderRadius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
            children: [
              SocialAvatar(
                imageUrl: friend.friendProfileImageUrl,
                name: friend.friendDisplayName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.friendDisplayName,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (friend.friendProvider != null) ...[
                      const SizedBox(height: 2),
                      _ProviderBadge(provider: friend.friendProvider!),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.person_remove_rounded,
                  size: 18,
                  color: colors.textDisabled,
                ),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
    );
  }
}

// ── OAuth 프로바이더 뱃지 ─────────────────────────────────────────
class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge({required this.provider});
  final String provider;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (provider.toLowerCase()) {
      'google' => ('Google', const Color(0xFF4285F4)),
      'naver'  => ('Naver',  const Color(0xFF03C75A)),
      'kakao'  => ('Kakao',  const Color(0xFFFEE500)),
      _        => (provider, const Color(0xFF525252)),
    };

    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── 친구 요청 타일 ────────────────────────────────────────────────
class FriendRequestTile extends StatelessWidget {
  const FriendRequestTile({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SocialAvatar(
            imageUrl: request.friendProfileImageUrl,
            name: request.friendDisplayName,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              request.friendDisplayName,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAccept,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(AppLocalizations.of(context)!.accept,
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final l10n = AppLocalizations.of(context)!;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: colors.card,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  content: Text(
                    l10n.friendRejectConfirm(request.friendDisplayName),
                    style: TextStyle(
                        color: colors.textSecondary, fontSize: 15),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.cancel,
                          style: TextStyle(color: colors.textMuted)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.reject,
                          style: TextStyle(color: colors.destructiveRed)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) onReject();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Text(AppLocalizations.of(context)!.reject,
                  style: TextStyle(
                      color: colors.textMuted,
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
class SocialAvatar extends StatelessWidget {
  const SocialAvatar({super.key, required this.name, this.imageUrl});
  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.secondary,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (c, o, e) => _Initials(name),
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
    final colors = context.colors;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── 내가 보낸 요청 타일 (모든 상태) ────────────────────────────────
class SentFriendRequestTile extends StatelessWidget {
  const SentFriendRequestTile({
    super.key,
    required this.request,
    this.onCancel,
  });
  final SentFriendRequest request;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    final (badgeColor, badgeIcon, statusText) = switch (request.status) {
      SentRequestStatus.pending => (
          const Color(0xFFFF9F0A),
          Icons.schedule_rounded,
          l10n.sentRequestAwaiting,
        ),
      SentRequestStatus.accepted => (
          const Color(0xFF34C759),
          Icons.check_rounded,
          l10n.sentRequestAccepted,
        ),
      SentRequestStatus.rejected => (
          Colors.redAccent,
          Icons.close_rounded,
          l10n.sentRequestRejected,
        ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // 아바타 + 상태 배지
          Stack(
            clipBehavior: Clip.none,
            children: [
              SocialAvatar(
                imageUrl: request.receiverProfileImageUrl,
                name: request.receiverDisplayName,
              ),
              Positioned(
                right: -3,
                bottom: -3,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.card, width: 1.5),
                  ),
                  child: Icon(badgeIcon, size: 9, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // 이름 + 상태 서브텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.receiverDisplayName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    color: colors.textDisabled,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // 취소 버튼 (pending만)
          if (request.status == SentRequestStatus.pending && onCancel != null)
            GestureDetector(
              onTap: () async {
                final l10n = AppLocalizations.of(context)!;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: colors.card,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    content: Text(
                      l10n.friendRequestCancelConfirm(
                          request.receiverDisplayName),
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 15),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(l10n.cancel,
                            style: TextStyle(color: colors.textMuted)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(l10n.friendRequestCancel,
                            style: TextStyle(color: colors.destructiveRed)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) onCancel!();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border, width: 0.5),
                ),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────────
class EmptyFriendsList extends StatelessWidget {
  const EmptyFriendsList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_outline_rounded,
            size: 52, color: colors.textDisabled),
        const SizedBox(height: 16),
        Text(
          l10n.friendsEmpty,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.friendsEmptySubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textDisabled,
            fontSize: 13,
            letterSpacing: -0.1,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
