import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../ledger/domain/models/ledger_summary.dart';
import '../../../ledger/presentation/providers/ledger_provider.dart';
import '../../data/repositories/todo_statistics_repository.dart';
import '../../domain/models/todo_statistics.dart';

part 'home_provider.g.dart';

typedef YearMonth = ({int year, int month});

@riverpod
class CurrentBranchIndex extends _$CurrentBranchIndex {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

@riverpod
class HomeMonth extends _$HomeMonth {
  @override
  YearMonth build() {
    final now = DateTime.now();
    return (year: now.year, month: now.month);
  }

  void set(YearMonth month) => state = month;
}

@riverpod
class HomeTodoStatistics extends _$HomeTodoStatistics {
  @override
  Future<TodoStatistics> build() {
    final month = ref.watch(homeMonthProvider);
    return ref
        .read(todoStatisticsRepositoryProvider)
        .fetchStatistics(month.year, month.month);
  }
}

@riverpod
class HomeLedgerSummary extends _$HomeLedgerSummary {
  @override
  Future<LedgerSummary> build() {
    final month = ref.watch(homeMonthProvider);
    return ref
        .read(ledgerEntryRepositoryProvider)
        .fetchSummary(month.year, month.month);
  }
}
