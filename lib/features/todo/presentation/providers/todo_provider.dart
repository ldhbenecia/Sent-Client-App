import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/todo_repository.dart';
import '../../domain/models/todo_category.dart';
import '../../domain/models/todo_item.dart';
import '../../../home/presentation/providers/home_provider.dart';

part 'todo_provider.g.dart';

typedef YearMonth = ({int year, int month});

@riverpod
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepository(ref.watch(dioProvider));
}

@riverpod
TodoRepository todoRepository(Ref ref) {
  return TodoRepository(ref.watch(dioProvider));
}

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void set(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

@riverpod
class FocusedMonth extends _$FocusedMonth {
  @override
  YearMonth build() {
    final now = DateTime.now();
    return (year: now.year, month: now.month);
  }

  void set(YearMonth month) => state = month;
}

@riverpod
class TodoCategories extends _$TodoCategories {
  @override
  Future<List<TodoCategory>> build() =>
      ref.read(categoryRepositoryProvider).fetchAll();

  Future<void> add({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final created = await ref
        .read(categoryRepositoryProvider)
        .create(name: name, icon: icon, color: color);
    state = AsyncData([...state.requireValue, created]);
  }

  Future<void> edit(TodoCategory category) async {
    final updated = await ref.read(categoryRepositoryProvider).update(category);
    state = AsyncData(
      state.requireValue.map((c) => c.id == category.id ? updated : c).toList(),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(categoryRepositoryProvider).delete(id);
    state = AsyncData(state.requireValue.where((c) => c.id != id).toList());
  }
}

@riverpod
class TodoItems extends _$TodoItems {
  @override
  Future<List<TodoItem>> build() {
    final month = ref.watch(focusedMonthProvider);
    return ref
        .read(todoRepositoryProvider)
        .fetchByMonth(month.year, month.month);
  }

  Future<void> add(TodoItem item) async {
    final created = await ref
        .read(todoRepositoryProvider)
        .create(
          title: item.title,
          date: item.date,
          categoryId: item.categoryId,
          time: item.time,
        );
    state = AsyncData([...state.requireValue, created]);
    ref.invalidate(homeTodoStatisticsProvider);
  }

  Future<void> edit(TodoItem item) async {
    final prev = state.requireValue;
    state = AsyncData(prev.map((t) => t.id == item.id ? item : t).toList());
    try {
      final updated = await ref.read(todoRepositoryProvider).update(item);
      state = AsyncData(
        state.requireValue.map((t) => t.id == item.id ? updated : t).toList(),
      );
      ref.invalidate(homeTodoStatisticsProvider);
    } on DioException {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final prev = state.requireValue;
    state = AsyncData(prev.where((t) => t.id != id).toList());
    try {
      await ref.read(todoRepositoryProvider).delete(id);
      ref.invalidate(homeTodoStatisticsProvider);
    } on DioException {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> toggleDone(String id) async {
    final todos = state.requireValue;
    final todo = todos.firstWhere((t) => t.id == id);
    final newDone = !todo.isDone;

    state = AsyncData(
      todos.map((t) => t.id == id ? t.toggleDone() : t).toList(),
    );
    try {
      await ref.read(todoRepositoryProvider).markDone(id, newDone);
      ref.invalidate(homeTodoStatisticsProvider);
    } on DioException {
      state = AsyncData(todos);
      rethrow;
    }
  }
}

@riverpod
Map<String?, List<TodoItem>> todosForSelectedDate(Ref ref) {
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
}

@riverpod
Set<DateTime> datesWithTodos(Ref ref) {
  return ref
          .watch(todoItemsProvider)
          .valueOrNull
          ?.map((t) => DateTime(t.date.year, t.date.month, t.date.day))
          .toSet() ??
      {};
}
