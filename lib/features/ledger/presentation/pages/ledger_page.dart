import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                children: [
                  Text(
                    l10n.ledgerDeleteTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.ledgerDeleteMessage,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
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
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(width: 0.5, height: 48, color: colors.border),
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
                    child: Text(
                      l10n.delete,
                      style: TextStyle(
                        color: colors.destructiveRed,
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
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
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('SENT'),
        actions: [
          IconButton(
            icon: Icon(
              _showCalendar
                  ? Icons.view_list_rounded
                  : Icons.calendar_month_rounded,
              color: colors.textMuted,
              size: 20,
            ),
            onPressed: () => setState(() {
              _showCalendar = !_showCalendar;
              _selectedDay = null;
            }),
          ),
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: colors.textMuted,
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
                  icon: Icon(Icons.chevron_left_rounded,
                      color: colors.textMuted),
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
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_selectedDay != null)
                        Text(
                          DateFormat.MMMd(locale).format(_selectedDay!),
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(month, 1),
                  icon: Icon(Icons.chevron_right_rounded,
                      color: colors.textMuted),
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
            Divider(height: 1, color: colors.border),

          // ── 항목 리스트 ──────────────────────────────────────────
          Expanded(
            child: entriesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: colors.textMuted,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  l10n.loadFailed,
                  style: TextStyle(color: colors.textMuted),
                ),
              ),
              data: (_) {
                if (displayedEntries.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedDay != null
                          ? l10n.ledgerEmptyDay
                          : l10n.ledgerEmptyMonth,
                      style: TextStyle(
                        color: colors.textMuted,
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
        heroTag: 'ledger_fab',
        onPressed: () {
          ref.read(ledgerNewEntryInitialDateProvider.notifier).state =
              _selectedDay;
          context.push('/ledger/new');
        },
        backgroundColor: colors.card,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        shape: CircleBorder(
          side: BorderSide(color: colors.border),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = '${DateFormat.MMMd(locale).format(date)} (${DateFormat.E(locale).format(date)})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Text(
            dateLabel,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Column(
            children: [
              for (int i = 0; i < entries.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 0.5,
                    color: colors.border,
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
