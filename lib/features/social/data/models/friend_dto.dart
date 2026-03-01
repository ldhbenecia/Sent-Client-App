import '../../domain/models/friend.dart';

class FriendDto {
  const FriendDto({
    required this.id,
    required this.friendId,
    required this.friendDisplayName,
    this.friendProfileImageUrl,
    this.friendProvider,
  });

  final int id;
  final String friendId;
  final String friendDisplayName;
  final String? friendProfileImageUrl;
  final String? friendProvider;

  factory FriendDto.fromJson(Map<String, dynamic> json) => FriendDto(
        id: json['id'] as int,
        friendId: json['friendId'] as String,
        friendDisplayName: json['friendDisplayName'] as String,
        friendProfileImageUrl: json['friendProfileImageUrl'] as String?,
        friendProvider: json['friendProvider'] as String?,
      );

  Friend toDomain() => Friend(
        id: id,
        friendId: friendId,
        friendDisplayName: friendDisplayName,
        friendProfileImageUrl: friendProfileImageUrl,
        friendProvider: friendProvider,
      );
}

class FriendRequestDto {
  const FriendRequestDto({
    required this.id,
    required this.friendId,
    required this.friendDisplayName,
    this.friendProfileImageUrl,
  });

  final int id;
  final String friendId;
  final String friendDisplayName;
  final String? friendProfileImageUrl;

  factory FriendRequestDto.fromJson(Map<String, dynamic> json) =>
      FriendRequestDto(
        id: json['id'] as int,
        friendId: json['friendId'] as String,
        friendDisplayName: json['friendDisplayName'] as String,
        friendProfileImageUrl: json['friendProfileImageUrl'] as String?,
      );

  FriendRequest toDomain() => FriendRequest(
        id: id,
        friendId: friendId,
        friendDisplayName: friendDisplayName,
        friendProfileImageUrl: friendProfileImageUrl,
      );
}

class SentFriendRequestDto {
  const SentFriendRequestDto({
    required this.id,
    required this.receiverDisplayName,
    this.receiverProfileImageUrl,
    required this.status,
  });

  final int id;
  final String receiverDisplayName;
  final String? receiverProfileImageUrl;
  final String status;

  factory SentFriendRequestDto.fromJson(Map<String, dynamic> json) =>
      SentFriendRequestDto(
        id: json['id'] as int,
        // 백엔드가 FriendResponse 재사용 시 friendDisplayName 사용
        receiverDisplayName:
            (json['receiverDisplayName'] ?? json['friendDisplayName'] ?? '') as String,
        receiverProfileImageUrl:
            (json['receiverProfileImageUrl'] ?? json['friendProfileImageUrl']) as String?,
        status: (json['status'] ?? 'PENDING') as String,
      );

  SentFriendRequest toDomain() => SentFriendRequest(
        id: id,
        receiverDisplayName: receiverDisplayName,
        receiverProfileImageUrl: receiverProfileImageUrl,
        status: switch (status.toUpperCase()) {
          'ACCEPTED' => SentRequestStatus.accepted,
          'REJECTED' => SentRequestStatus.rejected,
          _ => SentRequestStatus.pending,
        },
      );
}
