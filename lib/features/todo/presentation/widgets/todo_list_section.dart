import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../shared/theme/app_colors.dart';
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
