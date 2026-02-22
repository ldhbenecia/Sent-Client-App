import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_calendar.dart';
import '../widgets/todo_list_section.dart';
import '../widgets/todo_menu_card.dart';

const _kDevMode = bool.fromEnvironment('DEV_MODE', defaultValue: false);

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
    final next = DateTime(_focusedDay.year + yearDelta,
        _focusedDay.month + monthDelta);
    setState(() => _focusedDay = next);
    ref.read(focusedMonthProvider.notifier).state =
        (year: next.year, month: next.month);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final datesWithTodos = ref.watch(datesWithTodosProvider);
    final grouped = ref.watch(todosForSelectedDateProvider);
    final todosAsync = ref.watch(todoItemsProvider);
    final categories =
        ref.watch(todoCategoriesProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SENT'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu_rounded,
              color: AppColors.textMuted,
              size: 22,
            ),
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
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border, width: 0.5),
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
                        ref.read(selectedDateProvider.notifier).state =
                            DateTime(selected.year, selected.month, selected.day);
                        setState(() => _focusedDay = focused);
                      },
                      onPageChanged: (focused) {
                        setState(() => _focusedDay = focused);
                        ref.read(focusedMonthProvider.notifier).state =
                            (year: focused.year, month: focused.month);
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
                          const labels = [
                            '일', '월', '화', '수', '목', '금', '토'
                          ];
                          final isSun = day.weekday == DateTime.sunday;
                          final isSat = day.weekday == DateTime.saturday;
                          return Center(
                            child: Text(
                              labels[day.weekday % 7],
                              style: TextStyle(
                                color: isSun || isSat
                                    ? AppColors.textDisabled
                                    : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          );
                        },
                        defaultBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                              DateTime(day.year, day.month, day.day));
                          return buildTodoDayCell(day,
                              isSelected: false,
                              isToday: false,
                              isOutside: false,
                              hasTodo: hasTodo);
                        },
                        outsideBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                              DateTime(day.year, day.month, day.day));
                          return buildTodoDayCell(day,
                              isSelected: false,
                              isToday: false,
                              isOutside: true,
                              hasTodo: hasTodo);
                        },
                        todayBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                              DateTime(day.year, day.month, day.day));
                          return buildTodoDayCell(day,
                              isSelected: false,
                              isToday: true,
                              isOutside: false,
                              hasTodo: hasTodo);
                        },
                        selectedBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                              DateTime(day.year, day.month, day.day));
                          return buildTodoDayCell(day,
                              isSelected: true,
                              isToday: isSameDay(day, DateTime.now()),
                              isOutside: false,
                              hasTodo: hasTodo);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 0.5, color: AppColors.border),

          // ── 투두 리스트 ─────────────────────────────────────────
          Expanded(
            child: todosAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          color: AppColors.textDisabled, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(todoItemsProvider),
                        child: const Text('다시 시도',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13)),
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        return FadeTransition(
          opacity: anim,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: anim.value * 10,
                  sigmaY: anim.value * 10,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.35 * anim.value),
                ),
              ),
              Center(
                child: ScaleTransition(
                  scale: Tween(begin: 0.92, end: 1.0).animate(
                    CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic),
                  ),
                  child: TodoMenuCard(
                    onCategoryTap: () {
                      Navigator.of(ctx).pop();
                      context.push('/todo/categories');
                    },
                    onDevLogout: _kDevMode
                        ? () {
                            Navigator.of(ctx).pop();
                            context.go('/auth/login');
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
