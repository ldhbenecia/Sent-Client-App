import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/theme/app_color_theme.dart';
import '../../../../../shared/utils/haptics.dart';
import '../providers/todo_provider.dart';
import '../../domain/models/todo_category.dart';
import '../../domain/models/todo_item.dart';
import 'todo_tile.dart';

// ══════════════════════════════════════════════════════════════════
// 투두 리스트 섹션
// ══════════════════════════════════════════════════════════════════
class TodoListSection extends ConsumerWidget {
  const TodoListSection({
    super.key,
    required this.selectedDate,
    required this.grouped,
    required this.categories,
  });

  final DateTime selectedDate;
  final Map<String?, List<TodoItem>> grouped;
  final List<TodoCategory> categories;

  String _dateLabel(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date == today) return l10n.today;
    return DateFormat.MMMd(locale).format(date);
  }

  String _remainingText(AppLocalizations l10n, Map<String?, List<TodoItem>> grouped) {
    final all = grouped.values.expand((e) => e).toList();
    final remaining = all.where((t) => !t.isDone).length;
    if (all.isEmpty) return '';
    if (remaining == 0) return l10n.allDone;
    return l10n.remainingCount(remaining);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final allTodos = grouped.values.expand((e) => e).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate == today;

    return RefreshIndicator(
      color: colors.textPrimary,
      backgroundColor: colors.card,
      onRefresh: () => ref.refresh(todoItemsProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        // 날짜 헤더
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _dateLabel(context, selectedDate),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                if (allTodos.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _remainingText(l10n, grouped),
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Haptics.light();
                      context.push('/todo/new', extra: {'date': selectedDate});
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: colors.textPrimary,
                        size: 18,
                      ),
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
                      color: colors.textMuted,
                      icon: Icons.circle_outlined,
                    ),
                  )
                : null;

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: colors.border, width: 0.5),
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
                              Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: colors.border,
                                indent: 50,
                              ),
                            TodoTile(
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

        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    ),
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isToday ? l10n.todoAddTask : l10n.todoEmptyTitle,
            style: TextStyle(
              color: colors.textDisabled,
              fontSize: 14,
            ),
          ),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.take(4).map((cat) {
                return Material(
                  color: colors.secondary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Haptics.light();
                      context.push('/todo/new', extra: {
                        'date': selectedDate,
                        'categoryId': cat.id,
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: colors.border, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              size: 13, color: colors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            cat.name,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
          color: category.color.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: category.color.withValues(alpha: 0.35),
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
