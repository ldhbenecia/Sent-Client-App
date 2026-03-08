import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_calendar.dart';
import '../widgets/todo_list_section.dart';
import '../../../../shared/widgets/app_nav_menu.dart';

// ══════════════════════════════════════════════════════════════════
// TodoPage
// ══════════════════════════════════════════════════════════════════
class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = ref.read(selectedDateProvider);
  }

  void _changeMonth(int yearDelta, int monthDelta) {
    final next = DateTime(
      _focusedDay.year + yearDelta,
      _focusedDay.month + monthDelta,
    );
    setState(() => _focusedDay = next);
    ref.read(focusedMonthProvider.notifier).set((
      year: next.year,
      month: next.month,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(selectedDateProvider);
    final datesWithTodos = ref.watch(datesWithTodosProvider);
    final grouped = ref.watch(todosForSelectedDateProvider);
    final todosAsync = ref.watch(todoItemsProvider);
    final categories = ref.watch(todoCategoriesProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Text('SENT'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: colors.textMuted, size: 22),
            onPressed: () => _showMenu(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── 캘린더 ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  TodoCalendarHeader(
                    focusedDay: _focusedDay,
                    isLoading: todosAsync.isLoading,
                    onPrev: () => _changeMonth(0, -1),
                    onNext: () => _changeMonth(0, 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: TableCalendar(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2030),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, selectedDate),
                      onDaySelected: (selected, focused) {
                        ref.read(selectedDateProvider.notifier).set(selected);
                        setState(() => _focusedDay = focused);
                      },
                      onPageChanged: (focused) {
                        setState(() => _focusedDay = focused);
                        ref.read(focusedMonthProvider.notifier).set((
                          year: focused.year,
                          month: focused.month,
                        ));
                      },
                      headerVisible: false,
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      daysOfWeekHeight: 28,
                      rowHeight: 50,
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: true,
                        cellMargin: EdgeInsets.zero,
                        cellPadding: EdgeInsets.zero,
                      ),
                      calendarBuilders: CalendarBuilders(
                        dowBuilder: (context, day) {
                          final locale = Localizations.localeOf(
                            context,
                          ).toString();
                          final label = DateFormat.E(locale).format(day);
                          final isSun = day.weekday == DateTime.sunday;
                          final isSat = day.weekday == DateTime.saturday;
                          return Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSun || isSat
                                    ? colors.textDisabled
                                    : colors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          );
                        },
                        defaultBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                            DateTime(day.year, day.month, day.day),
                          );
                          return buildTodoDayCell(
                            context,
                            day,
                            isSelected: false,
                            isToday: false,
                            isOutside: false,
                            hasTodo: hasTodo,
                          );
                        },
                        outsideBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                            DateTime(day.year, day.month, day.day),
                          );
                          return buildTodoDayCell(
                            context,
                            day,
                            isSelected: false,
                            isToday: false,
                            isOutside: true,
                            hasTodo: hasTodo,
                          );
                        },
                        todayBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                            DateTime(day.year, day.month, day.day),
                          );
                          return buildTodoDayCell(
                            context,
                            day,
                            isSelected: false,
                            isToday: true,
                            isOutside: false,
                            hasTodo: hasTodo,
                          );
                        },
                        selectedBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                            DateTime(day.year, day.month, day.day),
                          );
                          return buildTodoDayCell(
                            context,
                            day,
                            isSelected: true,
                            isToday: isSameDay(day, DateTime.now()),
                            isOutside: false,
                            hasTodo: hasTodo,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, thickness: 0.5, color: colors.border),

          // ── 투두 리스트 ─────────────────────────────────────────
          Expanded(
            child: todosAsync.when(
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.textMuted,
                  ),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        color: colors.textDisabled,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: TextStyle(
                          color: colors.textDisabled,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(todoItemsProvider),
                        child: Text(
                          l10n.retry,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (_) => TodoListSection(
                selectedDate: selectedDate,
                grouped: grouped,
                categories: categories,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showAppNavMenu(
      context,
      onCategoryTap: () => context.push('/todo/categories'),
    );
  }
}
