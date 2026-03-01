class Friend {
  const Friend({
    required this.id,
    required this.friendId,
    required this.friendDisplayName,
    this.friendProfileImageUrl,
    this.friendProvider,
  });

  final int id;
  final String friendId; // UUID
  final String friendDisplayName;
  final String? friendProfileImageUrl;
  final String? friendProvider; // google, naver, kakao
}

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.friendId,
    required this.friendDisplayName,
    this.friendProfileImageUrl,
  });

  final int id;
  final String friendId; // 요청자 UUID
  final String friendDisplayName;
  final String? friendProfileImageUrl;
}

// ── 내가 보낸 친구 요청 ────────────────────────────────────────────
enum SentRequestStatus { pending, accepted, rejected }

class SentFriendRequest {
  const SentFriendRequest({
    required this.id,
    required this.receiverDisplayName,
    this.receiverProfileImageUrl,
    required this.status,
  });

  final int id;
  final String receiverDisplayName;
  final String? receiverProfileImageUrl;
  final SentRequestStatus status;
}
