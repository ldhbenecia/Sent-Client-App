import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/memo_category_repository.dart';
import '../../data/repositories/memo_repository.dart';
import '../../domain/models/memo_category.dart';
import '../../domain/models/memo_item.dart';

part 'memo_provider.g.dart';

@riverpod
MemoCategoryRepository memoCategoryRepository(Ref ref) {
  return MemoCategoryRepository(ref.watch(dioProvider));
}

@riverpod
MemoRepository memoRepository(Ref ref) {
  return MemoRepository(ref.watch(dioProvider));
}

@riverpod
class MemoCategories extends _$MemoCategories {
  @override
  Future<List<MemoCategory>> build() =>
      ref.read(memoCategoryRepositoryProvider).fetchAll();

  Future<void> add({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    final created = await ref
        .read(memoCategoryRepositoryProvider)
        .create(name: name, icon: icon, color: color);
    state = AsyncData([...state.requireValue, created]);
  }

  Future<void> edit(MemoCategory category) async {
    final updated =
        await ref.read(memoCategoryRepositoryProvider).update(category);
    state = AsyncData(
      state.requireValue
          .map((c) => c.id == category.id ? updated : c)
          .toList(),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(memoCategoryRepositoryProvider).delete(id);
    state = AsyncData(state.requireValue.where((c) => c.id != id).toList());
  }
}

@riverpod
class MemoItems extends _$MemoItems {
  @override
  Future<List<MemoItem>> build() =>
      ref.read(memoRepositoryProvider).fetchAll();

  Future<void> add({
    required String title,
    String? content,
    MemoCategory? category,
    List<String> tags = const [],
  }) async {
    final id = await ref.read(memoRepositoryProvider).create(
          title: title,
          content: content,
          categoryId: category?.id,
          tags: tags,
        );
    final newItem = MemoItem(
      id: id,
      title: title,
      content: content,
      category: category,
      tags: tags,
    );
    state = AsyncData([newItem, ...state.requireValue]);
  }

  Future<void> edit(
    MemoItem item, {
    required bool categoryIdUpdated,
  }) async {
    final prev = state.requireValue;
    state = AsyncData(prev.map((m) => m.id == item.id ? item : m).toList());
    try {
      await ref
          .read(memoRepositoryProvider)
          .update(item, categoryIdUpdated: categoryIdUpdated);
    } catch (_) {
      state = AsyncData(prev);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    final prev = state.requireValue;
    state = AsyncData(prev.where((m) => m.id != id).toList());
    try {
      await ref.read(memoRepositoryProvider).delete(id);
    } catch (_) {
      state = AsyncData(prev);
      rethrow;
    }
  }
}
