import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_nav_menu.dart';
import '../providers/ledger_provider.dart';
import '../widgets/ledger_summary_card.dart';
import '../widgets/ledger_entry_tile.dart';
import '../widgets/ledger_calendar_section.dart';
import '../../domain/models/ledger_category.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/models/ledger_summary.dart';

class LedgerPage extends ConsumerStatefulWidget {
  const LedgerPage({super.key});

  @override
  ConsumerState<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends ConsumerState<LedgerPage> {
  bool _showCalendar = true; // 기본값 달력 뷰
  DateTime? _selectedDay;

  Future<void> _confirmDelete(BuildContext context, String entryId) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                children: [
                  const Text(
                    '내역을 삭제할까요?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '삭제된 내역은 복구할 수 없습니다.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(width: 0.5, height: 48, color: AppColors.border),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    child: const Text(
                      '삭제',
                      style: TextStyle(
                        color: AppColors.destructiveRed,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      ref.read(ledgerEntriesProvider.notifier).remove(entryId);
    }
  }

  void _changeMonth(({int year, int month}) current, int delta) {
    final next = DateTime(current.year, current.month + delta);
    ref.read(ledgerMonthProvider.notifier).state =
        (year: next.year, month: next.month);
    setState(() => _selectedDay = null);
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      if (_selectedDay != null &&
          _selectedDay!.year == day.year &&
          _selectedDay!.month == day.month &&
          _selectedDay!.day == day.day) {
        _selectedDay = null; // 같은 날 다시 탭하면 선택 해제
      } else {
        _selectedDay = day;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(ledgerMonthProvider);
    final entriesAsync = ref.watch(ledgerEntriesProvider);
    final summaryAsync = ref.watch(ledgerSummaryProvider);
    final categories = ref.watch(ledgerCategoriesProvider).valueOrNull ?? [];
    final entriesByDate = ref.watch(entriesByDateProvider);

    final categoryMap = <String, LedgerCategory>{
      for (final c in categories) c.id: c,
    };

    // 날짜 선택 시 해당 날짜 항목만, 아니면 전체
    final Map<DateTime, List<LedgerEntry>> displayedEntries;
    if (_selectedDay != null) {
      final key = DateTime(
          _selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      final dayEntries = entriesByDate[key];
      displayedEntries = dayEntries != null ? {key: dayEntries} : {};
    } else {
      displayedEntries = entriesByDate;
    }

    final focusedMonth = DateTime(month.year, month.month);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SENT'),
        actions: [
          IconButton(
            icon: Icon(
              _showCalendar
                  ? Icons.view_list_rounded
                  : Icons.calendar_month_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
            onPressed: () => setState(() {
              _showCalendar = !_showCalendar;
              _selectedDay = null;
            }),
          ),
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
            onPressed: () => showAppNavMenu(
              context,
              onLedgerCategoryTap: () =>
                  context.push('/ledger/categories'),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── 월 네비게이션 ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(month, -1),
                  icon: const Icon(Icons.chevron_left_rounded,
                      color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                GestureDetector(
                  onTap: _selectedDay != null
                      ? () => setState(() => _selectedDay = null)
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${month.year}.${month.month.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_selectedDay != null)
                        Text(
                          '${_selectedDay!.month}월 ${_selectedDay!.day}일',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(month, 1),
                  icon: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),

          // ── 요약 카드 ────────────────────────────────────────────
          summaryAsync.when(
            data: (summary) => LedgerSummaryCard(summary: summary),
            loading: () => LedgerSummaryCard(summary: LedgerSummary.empty()),
            error: (_, _) =>
                LedgerSummaryCard(summary: LedgerSummary.empty()),
          ),

          // ── 달력 뷰 (토글) ──────────────────────────────────────
          if (_showCalendar)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: LedgerCalendarSection(
                focusedMonth: focusedMonth,
                selectedDay: _selectedDay,
                onDaySelected: _onDaySelected,
              ),
            ),

          if (_showCalendar)
            const Divider(height: 1, color: AppColors.border),

          // ── 항목 리스트 ──────────────────────────────────────────
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.textMuted,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => const Center(
                child: Text(
                  '불러오기 실패',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              data: (_) {
                if (displayedEntries.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedDay != null
                          ? '이 날 내역이 없습니다'
                          : '이번 달 내역이 없습니다',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                final dates = displayedEntries.keys.toList();
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final dayEntries = displayedEntries[date]!;
                    return _DateGroup(
                      date: date,
                      entries: dayEntries,
                      categoryMap: categoryMap,
                      onEntryTap: (entry) => context.push(
                        '/ledger/${entry.id}/edit',
                        extra: entry,
                      ),
                      onEntryDelete: (entry) =>
                          _confirmDelete(context, entry.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(ledgerNewEntryInitialDateProvider.notifier).state =
              _selectedDay;
          context.push('/ledger/new');
        },
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.border),
        ),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ── 날짜 그룹 위젯 ─────────────────────────────────────────────────
class _DateGroup extends StatelessWidget {
  const _DateGroup({
    required this.date,
    required this.entries,
    required this.categoryMap,
    required this.onEntryTap,
    required this.onEntryDelete,
  });

  final DateTime date;
  final List<LedgerEntry> entries;
  final Map<String, LedgerCategory> categoryMap;
  final void Function(LedgerEntry) onEntryTap;
  final void Function(LedgerEntry) onEntryDelete;

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdays[date.weekday - 1];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            '${date.month}월 ${date.day}일 ($weekday)',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < entries.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 0.5,
                    color: AppColors.border,
                    indent: 16,
                    endIndent: 16,
                  ),
                LedgerEntryTile(
                  entry: entries[i],
                  category: categoryMap[entries[i].categoryId],
                  onTap: () => onEntryTap(entries[i]),
                  onDelete: () => onEntryDelete(entries[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
