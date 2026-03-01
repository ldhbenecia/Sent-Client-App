class ChatRoom {
  const ChatRoom({
    required this.roomId,
    required this.opponentId,
    required this.opponentName,
    this.opponentProfileImageUrl,
    this.lastMessage,
    this.lastMessageTimestamp,
  });

  final int roomId;
  final String opponentId; // UUID
  final String opponentName;
  final String? opponentProfileImageUrl;
  final String? lastMessage;
  final int? lastMessageTimestamp; // ms since epoch

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    // opponent: { userId, userName, userProfileImageUrl }
    final opponent = json['opponent'] as Map<String, dynamic>;

    // lastMessageTime은 LocalDateTime → ISO 8601 문자열
    final timeStr = json['lastMessageTime'] as String?;
    int? lastMs;
    if (timeStr != null) {
      try {
        lastMs = DateTime.parse(timeStr).millisecondsSinceEpoch;
      } catch (_) {}
    }

    return ChatRoom(
      roomId: (json['roomId'] as num).toInt(),
      opponentId: opponent['userId'] as String,
      opponentName: opponent['userName'] as String,
      opponentProfileImageUrl: opponent['userProfileImageUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTimestamp: lastMs,
    );
  }
}
