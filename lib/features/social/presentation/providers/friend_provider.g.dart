// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myProfileHash() => r'cf3bbc27ce75ed1a802fbab87859a85f52334a65';

/// See also [myProfile].
@ProviderFor(myProfile)
final myProfileProvider = AutoDisposeFutureProvider<UserProfile?>.internal(
  myProfile,
  name: r'myProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyProfileRef = AutoDisposeFutureProviderRef<UserProfile?>;
String _$friendsHash() => r'cba9336ebc98842db642d1e8693e1d6b190b5e7b';

/// See also [Friends].
@ProviderFor(Friends)
final friendsProvider =
    AutoDisposeAsyncNotifierProvider<Friends, List<Friend>>.internal(
      Friends.new,
      name: r'friendsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$friendsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Friends = AutoDisposeAsyncNotifier<List<Friend>>;
String _$sentRequestsHash() => r'496a59aefacf8f6a6c2404a43b5ff6df1d40d194';

/// See also [SentRequests].
@ProviderFor(SentRequests)
final sentRequestsProvider =
    AutoDisposeAsyncNotifierProvider<
      SentRequests,
      List<SentFriendRequest>
    >.internal(
      SentRequests.new,
      name: r'sentRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sentRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SentRequests = AutoDisposeAsyncNotifier<List<SentFriendRequest>>;
String _$pendingRequestsHash() => r'c6d8063a74f3131716335fe3b4a27ec927d0789d';

/// See also [PendingRequests].
@ProviderFor(PendingRequests)
final pendingRequestsProvider =
    AutoDisposeAsyncNotifierProvider<
      PendingRequests,
      List<FriendRequest>
    >.internal(
      PendingRequests.new,
      name: r'pendingRequestsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingRequestsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingRequests = AutoDisposeAsyncNotifier<List<FriendRequest>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
