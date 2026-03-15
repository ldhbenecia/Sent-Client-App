// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$memoCategoryRepositoryHash() =>
    r'e4529b1b8e2baaffc1c562fff06e3948c691e424';

/// See also [memoCategoryRepository].
@ProviderFor(memoCategoryRepository)
final memoCategoryRepositoryProvider =
    AutoDisposeProvider<MemoCategoryRepository>.internal(
      memoCategoryRepository,
      name: r'memoCategoryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memoCategoryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoCategoryRepositoryRef =
    AutoDisposeProviderRef<MemoCategoryRepository>;
String _$memoRepositoryHash() => r'55a1995208afd95e5df98965cce0f4ff8957da77';

/// See also [memoRepository].
@ProviderFor(memoRepository)
final memoRepositoryProvider = AutoDisposeProvider<MemoRepository>.internal(
  memoRepository,
  name: r'memoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$memoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MemoRepositoryRef = AutoDisposeProviderRef<MemoRepository>;
String _$memoCategoriesHash() => r'a8fa7d4ec03f05f7941866adb32acb9ede803568';

/// See also [MemoCategories].
@ProviderFor(MemoCategories)
final memoCategoriesProvider =
    AutoDisposeAsyncNotifierProvider<
      MemoCategories,
      List<MemoCategory>
    >.internal(
      MemoCategories.new,
      name: r'memoCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memoCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MemoCategories = AutoDisposeAsyncNotifier<List<MemoCategory>>;
String _$memoItemsHash() => r'f3ba3fe1557e0d49178751f68026c2b679800836';

/// See also [MemoItems].
@ProviderFor(MemoItems)
final memoItemsProvider =
    AutoDisposeAsyncNotifierProvider<MemoItems, List<MemoItem>>.internal(
      MemoItems.new,
      name: r'memoItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$memoItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MemoItems = AutoDisposeAsyncNotifier<List<MemoItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
