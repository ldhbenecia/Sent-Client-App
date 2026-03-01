import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/repositories/friend_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/friend.dart';
import '../../domain/models/user_profile.dart';

// ── 내 프로필 (JWT sub → GET /api/v1/users/{id}) ──────────────────
final myProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final token = await ref.watch(tokenStorageProvider).getAccessToken();
  if (token == null) return null;
  try {
    final parts = token.split('.');
    var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    final decoded = utf8.decode(base64.decode(payload));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    final userId = json['sub'] as String;
    return await ref.read(userRepositoryProvider).fetchProfile(userId);
  } catch (_) {
    return null;
  }
});

// ── Repository providers ───────────────────────────────────────────
final friendRepositoryProvider = Provider<FriendRepository>((ref) {
  return FriendRepository(ref.watch(dioProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(dioProvider));
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

  Future<void> delete(int friendId) async {
    await ref.read(friendRepositoryProvider).deleteFriend(friendId);
    state = AsyncData(
      state.requireValue.where((f) => f.id != friendId).toList(),
    );
  }
}

final friendsProvider =
    AsyncNotifierProvider<FriendsNotifier, List<Friend>>(FriendsNotifier.new);

// ── 내가 보낸 친구 요청 목록 ──────────────────────────────────────
class SentRequestsNotifier extends AsyncNotifier<List<SentFriendRequest>> {
  @override
  Future<List<SentFriendRequest>> build() =>
      ref.read(friendRepositoryProvider).fetchSentRequests();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(friendRepositoryProvider).fetchSentRequests(),
    );
  }
}

final sentRequestsProvider =
    AsyncNotifierProvider<SentRequestsNotifier, List<SentFriendRequest>>(
        SentRequestsNotifier.new);

// ── 받은 친구 요청 목록 ────────────────────────────────────────────
class PendingRequestsNotifier extends AsyncNotifier<List<FriendRequest>> {
  @override
  Future<List<FriendRequest>> build() =>
      ref.read(friendRepositoryProvider).fetchPendingRequests();

  Future<void> accept(int requestId) async {
    await ref.read(friendRepositoryProvider).acceptRequest(requestId);
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
