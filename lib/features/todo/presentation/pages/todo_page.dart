import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../../domain/models/todo_category.dart';
import '../../domain/models/todo_item.dart';

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
                  _CalendarHeader(
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
                          return _buildDayCell(day,
                              isSelected: false,
                              isToday: false,
                              isOutside: false,
                              hasTodo: hasTodo);
                        },
                        outsideBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                              DateTime(day.year, day.month, day.day));
                          return _buildDayCell(day,
                              isSelected: false,
                              isToday: false,
                              isOutside: true,
                              hasTodo: hasTodo);
                        },
                        todayBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                              DateTime(day.year, day.month, day.day));
                          return _buildDayCell(day,
                              isSelected: false,
                              isToday: true,
                              isOutside: false,
                              hasTodo: hasTodo);
                        },
                        selectedBuilder: (context, day, _) {
                          final hasTodo = datesWithTodos.contains(
                              DateTime(day.year, day.month, day.day));
                          return _buildDayCell(day,
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
              data: (_) => _TodoListSection(
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
                  child: _MenuCard(
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

// ══════════════════════════════════════════════════════════════════
// 캘린더 날짜 셀 (숫자 + 점을 하나의 Column으로)
// ══════════════════════════════════════════════════════════════════
Widget _buildDayCell(
  DateTime day, {
  required bool isSelected,
  required bool isToday,
  required bool isOutside,
  required bool hasTodo,
}) {
  final textColor = isSelected
      ? AppColors.background
      : isOutside
          ? AppColors.textDisabled
          : AppColors.textPrimary;

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: isSelected
              ? const BoxDecoration(
                  color: AppColors.foreground,
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
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: hasTodo
                ? (isSelected
                    ? AppColors.textDisabled
                    : AppColors.textMuted)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
// 캘린더 커스텀 헤더
// ══════════════════════════════════════════════════════════════════
class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.focusedDay,
    required this.onPrev,
    required this.onNext,
    this.isLoading = false,
  });

  final DateTime focusedDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      child: Row(
        children: [
          Text(
            '${focusedDay.year}년 ${focusedDay.month}월',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.textDisabled,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onPrev,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.chevron_left_rounded,
                  size: 20, color: AppColors.textMuted),
            ),
          ),
          GestureDetector(
            onTap: onNext,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 투두 리스트 섹션
// ══════════════════════════════════════════════════════════════════
class _TodoListSection extends ConsumerWidget {
  const _TodoListSection({
    required this.selectedDate,
    required this.grouped,
    required this.categories,
  });

  final DateTime selectedDate;
  final Map<String?, List<TodoItem>> grouped;
  final List<TodoCategory> categories;

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date == today) return '오늘';
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return '${months[date.month - 1]} ${date.day}일';
  }

  String _remainingText(Map<String?, List<TodoItem>> grouped) {
    final all = grouped.values.expand((e) => e).toList();
    final remaining = all.where((t) => !t.isDone).length;
    if (all.isEmpty) return '';
    if (remaining == 0) return '전량 완료했습니다.';
    return '${remaining}개의 할 일이 남아있습니다.';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTodos = grouped.values.expand((e) => e).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate == today;

    return CustomScrollView(
      slivers: [
        // 날짜 헤더
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _dateLabel(selectedDate),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                if (allTodos.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _remainingText(grouped),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      context.push('/todo/new', extra: selectedDate),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 빈 상태
        if (allTodos.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyState(
              isToday: isToday,
              categories: categories,
              selectedDate: selectedDate,
            ),
          )
        else
          // 카테고리별 그룹 (카드 래퍼)
          ...grouped.entries.map((entry) {
            final catId = entry.key;
            final items = entry.value;
            final category = catId != null
                ? categories.firstWhere(
                    (c) => c.id == catId,
                    orElse: () => TodoCategory(
                      id: catId,
                      name: '기타',
                      color: AppColors.textMuted,
                      icon: Icons.circle_outlined,
                    ),
                  )
                : null;

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: const Color(0xFF2C2C2C), width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category != null)
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(14, 12, 14, 0),
                          child: _CategoryBadge(category: category),
                        ),
                      ...items.asMap().entries.map((e) {
                        final idx = e.key;
                        final item = e.value;
                        return Column(
                          children: [
                            if (idx > 0)
                              const Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: AppColors.border,
                                indent: 50,
                              ),
                            _TodoTile(
                              item: item,
                              onToggle: () => ref
                                  .read(todoItemsProvider.notifier)
                                  .toggleDone(item.id),
                              onEdit: () => context.push(
                                '/todo/${item.id}/edit',
                                extra: item,
                              ),
                              onDelete: () => ref
                                  .read(todoItemsProvider.notifier)
                                  .remove(item.id),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          }),

        const SliverPadding(padding: EdgeInsets.only(bottom: 110)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 빈 상태
// ══════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isToday,
    required this.categories,
    required this.selectedDate,
  });

  final bool isToday;
  final List<TodoCategory> categories;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isToday ? '할 일을 추가해보세요' : '할 일이 없습니다',
            style: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: 14,
            ),
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.take(4).map((cat) {
                return GestureDetector(
                  onTap: () =>
                      context.push('/todo/new', extra: selectedDate),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          cat.name,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 카테고리 배지 헤더
// ══════════════════════════════════════════════════════════════════
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final TodoCategory category;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.color.withOpacity(0.35),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 13, color: category.color),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: category.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 투두 아이템 타일
// ══════════════════════════════════════════════════════════════════
class _TodoTile extends StatelessWidget {
  const _TodoTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      item.isDone ? AppColors.textDisabled : Colors.transparent,
                  border: Border.all(
                    color: item.isDone
                        ? AppColors.textDisabled
                        : AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: item.isDone
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: AppColors.background)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: item.isDone
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textDisabled,
                    ),
                  ),
                  if (item.time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(item.time!),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _MoreButton(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ══════════════════════════════════════════════════════════════════
// ... 더보기 버튼
// ══════════════════════════════════════════════════════════════════
class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.more_horiz_rounded,
            size: 18, color: AppColors.textMuted),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 40),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              label: '수정',
              icon: Icons.edit_rounded,
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            Divider(
                height: 0.5,
                color: AppColors.border,
                indent: 16,
                endIndent: 16),
            _OptionTile(
              label: '삭제',
              icon: Icons.delete_outline_rounded,
              color: AppColors.destructiveRed,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: c, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 햄버거 메뉴 카드
// ══════════════════════════════════════════════════════════════════
class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.onCategoryTap, this.onDevLogout});

  final VoidCallback onCategoryTap;
  final VoidCallback? onDevLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xF00F0F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            child: Row(
              children: [
                const Text(
                  'Todos',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          _MenuRow(label: 'View', onTap: () => Navigator.of(context).pop()),
          _MenuRow(label: 'Category', onTap: onCategoryTap),
          _MenuRow(label: 'My', onTap: () => Navigator.of(context).pop()),
          _MenuRow(label: 'Alarm', onTap: () => Navigator.of(context).pop()),
          if (onDevLogout != null) ...[
            const Divider(height: 0.5, color: AppColors.border),
            _MenuRow(
              label: 'DEV Logout',
              color: AppColors.destructiveRed,
              onTap: onDevLogout!,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
