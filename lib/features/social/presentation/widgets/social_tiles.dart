import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../domain/models/friend.dart';

// ── 섹션 컨테이너 ──────────────────────────────────────────────────
class SocialSection extends StatelessWidget {
  const SocialSection({super.key, required this.label, required this.child});
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
class FriendTile extends StatelessWidget {
  const FriendTile({super.key, required this.friend, required this.onDelete});
  final Friend friend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SocialAvatar(
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
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.person_remove_rounded,
              size: 18,
              color: AppColors.textDisabled,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
class SocialAvatar extends StatelessWidget {
  const SocialAvatar({super.key, required this.name, this.imageUrl});
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
class EmptyFriendsList extends StatelessWidget {
  const EmptyFriendsList({super.key});

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
