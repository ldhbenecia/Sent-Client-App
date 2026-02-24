import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/friend_repository.dart';
import '../../domain/models/friend.dart';

// ── Repository provider ───────────────────────────────────────────
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.watch(dioProvider));
});

// ── 친구 목록 ─────────────────────────────────────────────────────
class FriendsNotifier extends AsyncNotifier<List<Friend>> {
  @override
  Future<List<Friend>> build() =>
      ref.read(friendRepositoryProvider).fetchAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(friendRepositoryProvider).fetchAll(),
    );
  }
}

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, List<Friend>>(FriendsNotifier.new);

// ── 받은 친구 요청 목록 ────────────────────────────────────────────
class PendingRequestsNotifier extends AsyncNotifier<List<FriendRequest>> {
  @override
  Future<List<FriendRequest>> build() =>
      ref.read(friendRepositoryProvider).fetchPendingRequests();

  Future<void> accept(int requestId) async {
    await ref.read(friendRepositoryProvider).acceptRequest(requestId);
    // 수락 후 양쪽 다 새로고침
    state = AsyncData(
      state.requireValue.where((r) => r.id != requestId).toList(),
    );
    ref.read(friendsProvider.notifier).refresh();
  }

  Future<void> reject(int requestId) async {
    await ref.read(friendRepositoryProvider).rejectRequest(requestId);
    state = AsyncData(
      state.requireValue.where((r) => r.id != requestId).toList(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(friendRepositoryProvider).fetchPendingRequests(),
    );
  }
}

final pendingRequestsProvider =
    AsyncNotifierProvider<PendingRequestsNotifier, List<FriendRequest>>(
        PendingRequestsNotifier.new);
