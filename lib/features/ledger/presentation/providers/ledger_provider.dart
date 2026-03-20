import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/ledger_category_repository.dart';
import '../../data/repositories/ledger_entry_repository.dart';
import '../../domain/models/ledger_category.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/models/ledger_enums.dart';
import '../../domain/models/ledger_summary.dart';

part 'ledger_provider.g.dart';

// ── Repository providers ───────────────────────────────────────────
final ledgerCategoryRepositoryProvider =
    Provider<LedgerCategoryRepository>((ref) {
  return LedgerCategoryRepository(ref.watch(dioProvider));
});

final ledgerEntryRepositoryProvider = Provider<LedgerEntryRepository>((ref) {
  return LedgerEntryRepository(ref.watch(dioProvider));
});

// ── 선택 월 상태 (ephemeral UI state → StateProvider 유지) ────────
final ledgerMonthProvider =
    StateProvider<({int year, int month})>((ref) {
  final now = DateTime.now();
  return (year: now.year, month: now.month);
});

// ── 새 항목 추가 시 기본 거래일 (ephemeral UI state → StateProvider 유지) ──
final ledgerNewEntryInitialDateProvider =
    StateProvider<DateTime?>((ref) => null);

// ══════════════════════════════════════════════════════════════════
// 카테고리 AsyncNotifier
// ══════════════════════════════════════════════════════════════════
@riverpod
class LedgerCategories extends _$LedgerCategories {
  @override
  Future<List<LedgerCategory>> build() =>
      ref.read(ledgerCategoryRepositoryProvider).fetchAll();

  Future<void> add({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final created = await ref.read(ledgerCategoryRepositoryProvider).create(
          name: name,
          icon: icon,
          color: color,
        );
    state = AsyncData([...state.requireValue, created]);
  }

  Future<void> edit(LedgerCategory category) async {
    final updated =
        await ref.read(ledgerCategoryRepositoryProvider).update(category);
    state = AsyncData(
      state.requireValue
          .map((c) => c.id == category.id ? updated : c)
          .toList(),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(ledgerCategoryRepositoryProvider).delete(id);
    state = AsyncData(
      state.requireValue.where((c) => c.id != id).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 항목 AsyncNotifier (월 단위)
// ══════════════════════════════════════════════════════════════════
@riverpod
class LedgerEntries extends _$LedgerEntries {
  @override
  Future<List<LedgerEntry>> build() {
    final month = ref.watch(ledgerMonthProvider);
    return ref
        .read(ledgerEntryRepositoryProvider)
        .fetchByMonth(month.year, month.month);
  }

  Future<void> add({
    required LedgerType type,
    required int amount,
    required PaymentMethod paymentMethod,
    String? categoryId,
    String? memo,
    required DateTime transactionDate,
  }) async {
    final created = await ref.read(ledgerEntryRepositoryProvider).create(
          type: type,
          amount: amount,
          paymentMethod: paymentMethod,
          categoryId: categoryId,
          memo: memo,
          transactionDate: transactionDate,
        );
    state = AsyncData([...state.requireValue, created]);
    // 통계도 갱신
    ref.invalidate(ledgerSummaryProvider);
  }

  Future<void> edit(LedgerEntry entry) async {
    final prev = state.requireValue;
    state = AsyncData(
        prev.map((e) => e.id == entry.id ? entry : e).toList());
    try {
      final updated =
          await ref.read(ledgerEntryRepositoryProvider).update(entry);
      state = AsyncData(
        state.requireValue
            .map((e) => e.id == entry.id ? updated : e)
            .toList(),
      );
      ref.invalidate(ledgerSummaryProvider);
    } catch (e) {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final prev = state.requireValue;
    state = AsyncData(prev.where((e) => e.id != id).toList());
    try {
      await ref.read(ledgerEntryRepositoryProvider).delete(id);
      ref.invalidate(ledgerSummaryProvider);
    } catch (e) {
      state = AsyncData(prev);
      rethrow;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// 월별 통계 (manual provider — LedgerSummary 도메인 모델과 이름 충돌 방지)
// ══════════════════════════════════════════════════════════════════
class LedgerSummaryNotifier extends AsyncNotifier<LedgerSummary> {
  @override
  Future<LedgerSummary> build() {
    final month = ref.watch(ledgerMonthProvider);
    return ref
        .read(ledgerEntryRepositoryProvider)
        .fetchSummary(month.year, month.month);
  }
}

final ledgerSummaryProvider =
    AsyncNotifierProvider<LedgerSummaryNotifier, LedgerSummary>(
  LedgerSummaryNotifier.new,
);

// ── 날짜별 그룹 파생 Provider ─────────────────────────────────────
@riverpod
Map<DateTime, List<LedgerEntry>> entriesByDate(Ref ref) {
  final entries = ref.watch(ledgerEntriesProvider).valueOrNull ?? [];
  final Map<DateTime, List<LedgerEntry>> grouped = {};
  for (final entry in entries) {
    final day = DateTime(
      entry.transactionDate.year,
      entry.transactionDate.month,
      entry.transactionDate.day,
    );
    grouped.putIfAbsent(day, () => []).add(entry);
  }
  // 날짜 내림차순 정렬
  final sorted = Map.fromEntries(
    grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)),
  );
  return sorted;
}

// ── 일별 지출/수입 합계 파생 Provider ────────────────────────────
@riverpod
Map<DateTime, ({int expense, int income})> ledgerDayTotals(Ref ref) {
  final entries = ref.watch(ledgerEntriesProvider).valueOrNull ?? [];
  final Map<DateTime, ({int expense, int income})> totals = {};
  for (final entry in entries) {
    final day = DateTime(
      entry.transactionDate.year,
      entry.transactionDate.month,
      entry.transactionDate.day,
    );
    final prev = totals[day] ?? (expense: 0, income: 0);
    totals[day] = entry.type == LedgerType.expense
        ? (expense: prev.expense + entry.amount, income: prev.income)
        : (expense: prev.expense, income: prev.income + entry.amount);
  }
  return totals;
}
