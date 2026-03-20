import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/chat_room.dart';

part 'chat_list_provider.g.dart';

@riverpod
class ChatList extends _$ChatList {
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
