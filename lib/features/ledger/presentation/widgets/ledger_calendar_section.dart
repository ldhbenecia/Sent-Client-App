import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../shared/theme/app_color_theme.dart';
import '../providers/ledger_provider.dart';

// ══════════════════════════════════════════════════════════════════
// LedgerCalendarSection — 달력 뷰 (일별 지출/수입 인디케이터)
// ══════════════════════════════════════════════════════════════════
class LedgerCalendarSection extends ConsumerWidget {
  const LedgerCalendarSection({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime? selectedDay;
  final void Function(DateTime day) onDaySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final dayTotals = ref.watch(ledgerDayTotalsProvider);
    final locale = Localizations.localeOf(context).toString();

    return TableCalendar(
      locale: locale,
      focusedDay: focusedMonth,
      firstDay: DateTime(2020),
      lastDay: DateTime(2030, 12, 31),
      currentDay: DateTime.now(),
      selectedDayPredicate: (day) =>
          selectedDay != null && isSameDay(day, selectedDay),
      onDaySelected: (selected, _) => onDaySelected(selected),
      // 헤더 숨김 — LedgerPage 의 월 네비게이션 재사용
      headerVisible: false,
      // 주간 뷰 고정
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: ''},
      startingDayOfWeek: StartingDayOfWeek.monday,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        weekendStyle: TextStyle(
          color: colors.textDisabled,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: EdgeInsets.zero,
        cellPadding: EdgeInsets.zero,
      ),
      rowHeight: 60,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) => _DayCell(
          day: day,
          totals: dayTotals[DateTime(day.year, day.month, day.day)],
          isSelected: false,
          isToday: false,
          isOutside: false,
        ),
        todayBuilder: (context, day, focusedDay) => _DayCell(
          day: day,
          totals: dayTotals[DateTime(day.year, day.month, day.day)],
          isSelected: selectedDay != null && isSameDay(day, selectedDay),
          isToday: true,
          isOutside: false,
        ),
        selectedBuilder: (context, day, focusedDay) => _DayCell(
          day: day,
          totals: dayTotals[DateTime(day.year, day.month, day.day)],
          isSelected: true,
          isToday: isSameDay(day, DateTime.now()),
          isOutside: false,
        ),
        outsideBuilder: (context, day, focusedDay) => _DayCell(
          day: day,
          totals: null,
          isSelected: false,
          isToday: false,
          isOutside: true,
        ),
      ),
    );
  }
}

// ── 날짜 셀 ────────────────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.totals,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
  });

  final DateTime day;
  final ({int expense, int income})? totals;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasData = totals != null &&
        (totals!.expense > 0 || totals!.income > 0);

    final textColor = isOutside
        ? Colors.transparent
        : isSelected
            ? colors.background
            : colors.textPrimary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
                  color: colors.textPrimary,
                  shape: BoxShape.circle,
                )
              : isToday
                  ? BoxDecoration(
                      border: Border.all(
                        color: colors.textMuted,
                        width: 1,
                      ),
                      shape: BoxShape.circle,
                    )
                  : null,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 3),
        if (hasData && !isOutside)
          _AmountIndicator(
            expense: totals!.expense,
            income: totals!.income,
            isSelected: isSelected,
          )
        else
          const SizedBox(height: 10),
      ],
    );
  }
}

// ── 금액 인디케이터 (지출=빨강 점, 수입=초록 점) ────────────────────
class _AmountIndicator extends StatelessWidget {
  const _AmountIndicator({
    required this.expense,
    required this.income,
    required this.isSelected,
  });

  final int expense;
  final int income;
  final bool isSelected;

  static const _expenseColor = Color(0xFFFF6B6B);
  static const _incomeColor = Color(0xFF4CAF82);

  @override
  Widget build(BuildContext context) {
    final hasExpense = expense > 0;
    final hasIncome = income > 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasExpense)
          Container(
            width: 5,
            height: 5,
            margin: EdgeInsets.only(right: hasIncome ? 2 : 0),
            decoration: BoxDecoration(
              color: isSelected
                  ? _expenseColor.withValues(alpha: 0.7)
                  : _expenseColor,
              shape: BoxShape.circle,
            ),
          ),
        if (hasIncome)
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isSelected
                  ? _incomeColor.withValues(alpha: 0.7)
                  : _incomeColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
