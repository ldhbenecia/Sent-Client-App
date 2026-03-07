import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ledger/domain/models/ledger_summary.dart';
import '../../../ledger/presentation/providers/ledger_provider.dart';
import '../../data/repositories/todo_statistics_repository.dart';
import '../../domain/models/todo_statistics.dart';

// ── 현재 브랜치(탭) 인덱스 ─────────────────────────────────────────
final currentBranchIndexProvider = StateProvider<int>((ref) => 0);

// ── 선택 월 상태 ───────────────────────────────────────────────────
final homeMonthProvider = StateProvider<({int year, int month})>((ref) {
  final now = DateTime.now();
  return (year: now.year, month: now.month);
});

// ── Todo 통계 ──────────────────────────────────────────────────────
final homeTodoStatisticsProvider =
    AsyncNotifierProvider<HomeTodoStatisticsNotifier, TodoStatistics>(
  HomeTodoStatisticsNotifier.new,
);

class HomeTodoStatisticsNotifier extends AsyncNotifier<TodoStatistics> {
  @override
  Future<TodoStatistics> build() {
    final month = ref.watch(homeMonthProvider);
    return ref
        .read(todoStatisticsRepositoryProvider)
        .fetchStatistics(month.year, month.month);
  }
}

// ── 가계부 요약 (기존 ledgerEntryRepositoryProvider 재사용) ─────────
final homeLedgerSummaryProvider =
    AsyncNotifierProvider<HomeLedgerSummaryNotifier, LedgerSummary>(
  HomeLedgerSummaryNotifier.new,
);

class HomeLedgerSummaryNotifier extends AsyncNotifier<LedgerSummary> {
  @override
  Future<LedgerSummary> build() {
    final month = ref.watch(homeMonthProvider);
    return ref
        .read(ledgerEntryRepositoryProvider)
        .fetchSummary(month.year, month.month);
  }
}
