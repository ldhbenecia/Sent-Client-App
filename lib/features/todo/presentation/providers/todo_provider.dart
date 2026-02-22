import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/todo_repository.dart';
import '../../domain/models/todo_category.dart';
import '../../domain/models/todo_item.dart';

// ── Repository providers ──────────────────────────────────────────
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(dioProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(dioProvider));
});

// ── 선택된 날짜 ──────────────────────────────────────────────────
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// ── 현재 보고 있는 달 (캘린더 월 이동 시 업데이트) ───────────────────
final focusedMonthProvider =
    StateProvider<({int year, int month})>((ref) {
  final now = DateTime.now();
  return (year: now.year, month: now.month);
});

// ══════════════════════════════════════════════════════════════════
// 카테고리 AsyncNotifier
// ══════════════════════════════════════════════════════════════════
final todoCategoriesProvider =
    AsyncNotifierProvider<TodoCategoriesNotifier, List<TodoCategory>>(
  TodoCategoriesNotifier.new,
);

class TodoCategoriesNotifier extends AsyncNotifier<List<TodoCategory>> {
  @override
  Future<List<TodoCategory>> build() =>
      ref.read(categoryRepositoryProvider).fetchAll();

  Future<void> add({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final created = await ref.read(categoryRepositoryProvider).create(
          name: name,
          icon: icon,
          color: color,
        );
    state = AsyncData([...state.requireValue, created]);
  }

  Future<void> edit(TodoCategory category) async {
    final updated =
        await ref.read(categoryRepositoryProvider).update(category);
    state = AsyncData(
      state.requireValue
          .map((c) => c.id == category.id ? updated : c)
          .toList(),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(categoryRepositoryProvider).delete(id);
    state = AsyncData(
      state.requireValue.where((c) => c.id != id).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 투두 아이템 AsyncNotifier (월 단위 로드)
// ══════════════════════════════════════════════════════════════════
final todoItemsProvider =
    AsyncNotifierProvider<TodoItemsNotifier, List<TodoItem>>(
  TodoItemsNotifier.new,
);

class TodoItemsNotifier extends AsyncNotifier<List<TodoItem>> {
  @override
  Future<List<TodoItem>> build() {
    final month = ref.watch(focusedMonthProvider);
    return ref
        .read(todoRepositoryProvider)
        .fetchByMonth(month.year, month.month);
  }

  Future<void> add(TodoItem item) async {
    final created = await ref.read(todoRepositoryProvider).create(
          title: item.title,
          date: item.date,
          categoryId: item.categoryId,
          time: item.time,
        );
    state = AsyncData([...state.requireValue, created]);
  }

  Future<void> edit(TodoItem item) async {
    // 낙관적 업데이트
    final prev = state.requireValue;
    state = AsyncData(prev.map((t) => t.id == item.id ? item : t).toList());
    try {
      final updated =
          await ref.read(todoRepositoryProvider).update(item);
      state = AsyncData(
        state.requireValue.map((t) => t.id == item.id ? updated : t).toList(),
      );
    } catch (e) {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    // 낙관적 삭제
    final prev = state.requireValue;
    state = AsyncData(prev.where((t) => t.id != id).toList());
    try {
      await ref.read(todoRepositoryProvider).delete(id);
    } catch (e) {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> toggleDone(String id) async {
    final todos = state.requireValue;
    final todo = todos.firstWhere((t) => t.id == id);
    final newDone = !todo.isDone;

    // 낙관적 업데이트
    state = AsyncData(
      todos.map((t) => t.id == id ? t.toggleDone() : t).toList(),
    );
    try {
      await ref.read(todoRepositoryProvider).markDone(id, newDone);
    } catch (e) {
      state = AsyncData(todos); // 롤백
      rethrow;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// 파생 Providers
// ══════════════════════════════════════════════════════════════════

/// 선택된 날짜의 투두를 카테고리별로 그룹핑
/// todoItemsProvider 로딩 중이면 빈 맵 반환
final todosForSelectedDateProvider =
    Provider<Map<String?, List<TodoItem>>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final todos = ref.watch(todoItemsProvider).valueOrNull ?? [];

  final filtered = todos
      .where(
        (t) =>
            t.date.year == date.year &&
            t.date.month == date.month &&
            t.date.day == date.day,
      )
      .toList();

  final Map<String?, List<TodoItem>> grouped = {};
  for (final todo in filtered) {
    grouped.putIfAbsent(todo.categoryId, () => []).add(todo);
  }
  return grouped;
});

/// 투두가 있는 날짜 집합 (캘린더 마커용)
final datesWithTodosProvider = Provider<Set<DateTime>>((ref) {
  return ref
          .watch(todoItemsProvider)
          .valueOrNull
          ?.map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .toSet() ??
      {};
});
