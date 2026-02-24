class Friend {
  const Friend({
    required this.id,
    required this.friendId,
    required this.friendDisplayName,
    this.friendProfileImageUrl,
  });

  final int id;
  final String friendId; // UUID
  final String friendDisplayName;
  final String? friendProfileImageUrl;
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
