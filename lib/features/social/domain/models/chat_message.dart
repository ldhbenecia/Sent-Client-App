class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final int roomId;
  final String senderId; // UUID
  final String senderName;
  final String content;
  final int timestamp; // ms since epoch

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // MongoDB ObjectId may come as {"$oid": "..."} or plain string
    final rawId = json['id'] ?? json['_id'];
    final id = rawId is Map ? (rawId['\$oid'] as String? ?? rawId.toString()) : (rawId as String);
    return ChatMessage(
      id: id,
      roomId: (json['roomId'] as num).toInt(),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? '',
      content: json['content'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
    );
  }
}
