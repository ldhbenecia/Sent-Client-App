import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_message.dart';

part 'chat_provider.g.dart';

// ══════════════════════════════════════════════════════════════════
// ChatState
// ══════════════════════════════════════════════════════════════════
class ChatState {
  const ChatState({
    required this.roomId,
    required this.messages,
    this.myUserId,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isConnected = false,
  });

  final int roomId;
  final List<ChatMessage> messages; // newest-first
  final String? myUserId;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isConnected;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isConnected,
  }) =>
      ChatState(
        roomId: roomId,
        messages: messages ?? this.messages,
        myUserId: myUserId,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isConnected: isConnected ?? this.isConnected,
      );
}

// ══════════════════════════════════════════════════════════════════
// ChatNotifier — opponentId(UUID)로 파라미터화
// ══════════════════════════════════════════════════════════════════
@riverpod
class ChatNotifier extends _$ChatNotifier {
  StompClient? _stompClient;

  @override
  Future<ChatState> build(String opponentId) async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    final myUserId = _extractSub(token);

    final repo = ref.read(chatRepositoryProvider);
    final roomId = await repo.createOrGetRoom(opponentId);
    final messages = await repo.getMessages(roomId);

    // newest-first 정렬
    final sorted = [...messages]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    _connectStomp(roomId, token);

    ref.onDispose(() {
      _stompClient?.deactivate();
    });

    return ChatState(
      roomId: roomId,
      messages: sorted,
      myUserId: myUserId,
      hasMore: messages.length >= 30,
    );
  }

  void _connectStomp(int roomId, String? token) {
    debugPrint('[STOMP] Connecting to ${AppConfig.apiBaseUrl}/ws-chat room=$roomId');
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${AppConfig.apiBaseUrl}/ws-chat',
        stompConnectHeaders:
            token != null ? {'Authorization': 'Bearer $token'} : {},
        reconnectDelay: const Duration(seconds: 5),
        onConnect: (frame) {
          debugPrint('[STOMP] Connected');
          _setConnected(true);
          _stompClient?.subscribe(
            destination: '/topic/chat.rooms.$roomId',
            callback: (frame) {
              if (frame.body == null) return;
              try {
                final decoded = jsonDecode(frame.body!);
                final map = decoded is Map<String, dynamic>
                    ? decoded
                    : Map<String, dynamic>.from(decoded as Map);
                final msg = ChatMessage.fromJson(map);
                debugPrint('[STOMP] Message received: ${msg.content}');
                _onMessageReceived(msg);
              } catch (e) {
                debugPrint('[STOMP] Parse error: $e  body=${frame.body}');
              }
            },
          );
        },
        onDisconnect: (_) {
          debugPrint('[STOMP] Disconnected');
          _setConnected(false);
        },
        onStompError: (frame) {
          debugPrint('[STOMP] STOMP error: ${frame.body}');
          _setConnected(false);
        },
        onWebSocketError: (error) {
          debugPrint('[STOMP] WebSocket error: $error');
          _setConnected(false);
        },
      ),
    );
    _stompClient!.activate();
  }

  void _setConnected(bool connected) {
    if (state case AsyncData(:final value)) {
      state = AsyncData(value.copyWith(isConnected: connected));
    }
  }

  void _onMessageReceived(ChatMessage message) {
    if (state case AsyncData(:final value)) {
      if (value.messages.any((m) => m.id == message.id)) return;
      state = AsyncData(value.copyWith(
        messages: [message, ...value.messages],
      ));
    }
  }

  Future<void> send(String content) async {
    if (_stompClient == null) return;
    if (state case AsyncData(:final value)) {
      if (!value.isConnected) {
        debugPrint('[STOMP] Send blocked: not connected');
        return;
      }
      debugPrint('[STOMP] Sending: $content');
      _stompClient!.send(
        destination: '/pub/chat.message.${value.roomId}',
        body: jsonEncode({'content': content}),
      );
      // STOMP 에코가 오지 않을 경우 REST 폴백
      Future.delayed(const Duration(milliseconds: 800), _refreshMessages);
    }
  }

  Future<void> _refreshMessages() async {
    if (state case AsyncData(:final value)) {
      try {
        final messages = await ref
            .read(chatRepositoryProvider)
            .getMessages(value.roomId);
        final sorted = [...messages]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = AsyncData(value.copyWith(
          messages: sorted,
          hasMore: messages.length >= 30,
        ));
      } catch (_) {}
    }
  }

  Future<void> loadMore() async {
    if (state case AsyncData(:final value)) {
      if (!value.hasMore || value.isLoadingMore) return;
      state = AsyncData(value.copyWith(isLoadingMore: true));
      try {
        final oldest = value.messages.isNotEmpty ? value.messages.last : null;
        final more = await ref.read(chatRepositoryProvider).getMessages(
              value.roomId,
              lastMessageTimestamp: oldest?.timestamp,
            );
        final merged = [...value.messages, ...more]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = AsyncData(value.copyWith(
          messages: merged,
          hasMore: more.length >= 30,
          isLoadingMore: false,
        ));
      } catch (_) {
        state = AsyncData(value.copyWith(isLoadingMore: false));
      }
    }
  }

  String? _extractSub(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded = utf8.decode(base64Decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['sub'] as String?;
    } catch (_) {
      return null;
    }
  }
}
