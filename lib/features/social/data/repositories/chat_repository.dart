import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/chat_room.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(dioProvider));

class ChatRepository {
  const ChatRepository(this._dio);

  final Dio _dio;

  // GET /api/v1/chat/rooms — 내 채팅방 목록 (최근 메시지 포함)
  Future<List<ChatRoom>> fetchRooms() async {
    try {
      final res = await _dio.get('/api/v1/chat/rooms');
      final list = res.data['data'] as List;
      return list
          .map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // POST /api/v1/chat/rooms?opponentId={UUID} — 방 생성 또는 기존 방 반환
  Future<int> createOrGetRoom(String opponentId) async {
    try {
      final res = await _dio.post(
        '/api/v1/chat/rooms',
        queryParameters: {'opponentId': opponentId},
      );
      return (res.data['data']['roomId'] as num).toInt();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // GET /api/v1/chat/rooms/{roomId}/messages
  Future<List<ChatMessage>> getMessages(
    int roomId, {
    int? lastMessageTimestamp,
    int size = 30,
  }) async {
    try {
      final res = await _dio.get(
        '/api/v1/chat/rooms/$roomId/messages',
        queryParameters: {
          'lastMessageTimestamp': lastMessageTimestamp,
          'size': size,
        },
      );
      final list = res.data['data'] as List;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
