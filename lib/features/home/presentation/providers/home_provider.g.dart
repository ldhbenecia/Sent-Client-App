// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentBranchIndexHash() =>
    r'674dd63370b4ca8f79ce2847198a2e1138aa3749';

/// See also [CurrentBranchIndex].
@ProviderFor(CurrentBranchIndex)
final currentBranchIndexProvider =
    AutoDisposeNotifierProvider<CurrentBranchIndex, int>.internal(
      CurrentBranchIndex.new,
      name: r'currentBranchIndexProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentBranchIndexHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentBranchIndex = AutoDisposeNotifier<int>;
String _$homeMonthHash() => r'39721fa253652ee39dc6b63596330a8fb05e12dc';

/// See also [HomeMonth].
@ProviderFor(HomeMonth)
final homeMonthProvider =
    AutoDisposeNotifierProvider<HomeMonth, YearMonth>.internal(
      HomeMonth.new,
      name: r'homeMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeMonth = AutoDisposeNotifier<YearMonth>;
String _$homeTodoStatisticsHash() =>
    r'04173b5c737e2818df6821b0fb8309b70d8e5a8b';

/// See also [HomeTodoStatistics].
@ProviderFor(HomeTodoStatistics)
final homeTodoStatisticsProvider =
    AutoDisposeAsyncNotifierProvider<
      HomeTodoStatistics,
      TodoStatistics
    >.internal(
      HomeTodoStatistics.new,
      name: r'homeTodoStatisticsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeTodoStatisticsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeTodoStatistics = AutoDisposeAsyncNotifier<TodoStatistics>;
String _$homeLedgerSummaryHash() => r'efb8ca22e2ac337209567748da2cb04de029c04c';

/// See also [HomeLedgerSummary].
@ProviderFor(HomeLedgerSummary)
final homeLedgerSummaryProvider =
    AutoDisposeAsyncNotifierProvider<HomeLedgerSummary, LedgerSummary>.internal(
      HomeLedgerSummary.new,
      name: r'homeLedgerSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeLedgerSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeLedgerSummary = AutoDisposeAsyncNotifier<LedgerSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
