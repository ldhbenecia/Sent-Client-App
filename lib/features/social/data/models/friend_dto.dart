import '../../domain/models/friend.dart';

class FriendDto {
  const FriendDto({
    required this.id,
    required this.friendId,
    required this.friendDisplayName,
    this.friendProfileImageUrl,
  });

  final int id;
  final String friendId;
  final String friendDisplayName;
  final String? friendProfileImageUrl;

  factory FriendDto.fromJson(Map<String, dynamic> json) => FriendDto(
        id: json['id'] as int,
        friendId: json['friendId'] as String,
        friendDisplayName: json['friendDisplayName'] as String,
        friendProfileImageUrl: json['friendProfileImageUrl'] as String?,
      );

  Friend toDomain() => Friend(
        id: id,
        friendId: friendId,
        friendDisplayName: friendDisplayName,
        friendProfileImageUrl: friendProfileImageUrl,
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
