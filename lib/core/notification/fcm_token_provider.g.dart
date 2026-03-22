// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fcmTokenRepositoryHash() =>
    r'ffedc5c9bd98a02b23ee7bcdea468ab8169ec7fe';

/// See also [fcmTokenRepository].
@ProviderFor(fcmTokenRepository)
final fcmTokenRepositoryProvider =
    AutoDisposeProvider<FcmTokenRepository>.internal(
      fcmTokenRepository,
      name: r'fcmTokenRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fcmTokenRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenRepositoryRef = AutoDisposeProviderRef<FcmTokenRepository>;
String _$registerFcmTokenHash() => r'b5f27ec965a187764a27a442200dbb9e19a7f1c5';

/// 로그인 후 호출 — FCM 토큰을 서버에 등록하고, 갱신 리스너도 설정
///
/// Copied from [registerFcmToken].
@ProviderFor(registerFcmToken)
final registerFcmTokenProvider = AutoDisposeFutureProvider<void>.internal(
  registerFcmToken,
  name: r'registerFcmTokenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$registerFcmTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RegisterFcmTokenRef = AutoDisposeFutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
