import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_room.dart';

class ChatListNotifier extends AsyncNotifier<List<ChatRoom>> {
  @override
  Future<List<ChatRoom>> build() =>
      ref.read(chatRepositoryProvider).fetchRooms();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(chatRepositoryProvider).fetchRooms(),
    );
  }
}

final chatListProvider =
    AsyncNotifierProvider<ChatListNotifier, List<ChatRoom>>(
        ChatListNotifier.new);
