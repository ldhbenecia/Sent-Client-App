// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$entriesByDateHash() => r'72c3ae8e5a832c5a0e907c12b3c181942e9ce49c';

/// See also [entriesByDate].
@ProviderFor(entriesByDate)
final entriesByDateProvider =
    AutoDisposeProvider<Map<DateTime, List<LedgerEntry>>>.internal(
      entriesByDate,
      name: r'entriesByDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$entriesByDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EntriesByDateRef =
    AutoDisposeProviderRef<Map<DateTime, List<LedgerEntry>>>;
String _$ledgerDayTotalsHash() => r'791e3951aed124ba4c19f0d8577c1db357d5d3ec';

/// See also [ledgerDayTotals].
@ProviderFor(ledgerDayTotals)
final ledgerDayTotalsProvider =
    AutoDisposeProvider<Map<DateTime, ({int expense, int income})>>.internal(
      ledgerDayTotals,
      name: r'ledgerDayTotalsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ledgerDayTotalsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LedgerDayTotalsRef =
    AutoDisposeProviderRef<Map<DateTime, ({int expense, int income})>>;
String _$ledgerCategoriesHash() => r'481f1e3eb5852187bc869729f833b450f407ccc7';

/// See also [LedgerCategories].
@ProviderFor(LedgerCategories)
final ledgerCategoriesProvider =
    AutoDisposeAsyncNotifierProvider<
      LedgerCategories,
      List<LedgerCategory>
    >.internal(
      LedgerCategories.new,
      name: r'ledgerCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ledgerCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LedgerCategories = AutoDisposeAsyncNotifier<List<LedgerCategory>>;
String _$ledgerEntriesHash() => r'ce732b7ca88aaca6c7c0ce02e68e652c4ab44f6c';

/// See also [LedgerEntries].
@ProviderFor(LedgerEntries)
final ledgerEntriesProvider =
    AutoDisposeAsyncNotifierProvider<LedgerEntries, List<LedgerEntry>>.internal(
      LedgerEntries.new,
      name: r'ledgerEntriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ledgerEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LedgerEntries = AutoDisposeAsyncNotifier<List<LedgerEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
