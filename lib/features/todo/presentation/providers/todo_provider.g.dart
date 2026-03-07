// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryRepositoryHash() =>
    r'683c969e4c2920a90ab4c431d5718eaf1033d3ec';

/// See also [categoryRepository].
@ProviderFor(categoryRepository)
final categoryRepositoryProvider =
    AutoDisposeProvider<CategoryRepository>.internal(
      categoryRepository,
      name: r'categoryRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryRepositoryRef = AutoDisposeProviderRef<CategoryRepository>;
String _$todoRepositoryHash() => r'50c5931c04ad6c397252235f7de7694ce16a8b0c';

/// See also [todoRepository].
@ProviderFor(todoRepository)
final todoRepositoryProvider = AutoDisposeProvider<TodoRepository>.internal(
  todoRepository,
  name: r'todoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodoRepositoryRef = AutoDisposeProviderRef<TodoRepository>;
String _$todosForSelectedDateHash() =>
    r'850f81f967c72bf00346f0be67a2a3c40c3b33bf';

/// See also [todosForSelectedDate].
@ProviderFor(todosForSelectedDate)
final todosForSelectedDateProvider =
    AutoDisposeProvider<Map<String?, List<TodoItem>>>.internal(
      todosForSelectedDate,
      name: r'todosForSelectedDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todosForSelectedDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodosForSelectedDateRef =
    AutoDisposeProviderRef<Map<String?, List<TodoItem>>>;
String _$datesWithTodosHash() => r'4450d4bcf505e2c22e80400c18153ddc60761231';

/// See also [datesWithTodos].
@ProviderFor(datesWithTodos)
final datesWithTodosProvider = AutoDisposeProvider<Set<DateTime>>.internal(
  datesWithTodos,
  name: r'datesWithTodosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$datesWithTodosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatesWithTodosRef = AutoDisposeProviderRef<Set<DateTime>>;
String _$selectedDateHash() => r'9a998ec6c89651f9a2a7659ef174743edba78750';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
      SelectedDate.new,
      name: r'selectedDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$focusedMonthHash() => r'db3222637be48d9614e8c4cec5affb9dc633558a';

/// See also [FocusedMonth].
@ProviderFor(FocusedMonth)
final focusedMonthProvider =
    AutoDisposeNotifierProvider<FocusedMonth, YearMonth>.internal(
      FocusedMonth.new,
      name: r'focusedMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$focusedMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FocusedMonth = AutoDisposeNotifier<YearMonth>;
String _$todoCategoriesHash() => r'f24394882d93796647a5cb324abf26ecf1f5726f';

/// See also [TodoCategories].
@ProviderFor(TodoCategories)
final todoCategoriesProvider =
    AutoDisposeAsyncNotifierProvider<
      TodoCategories,
      List<TodoCategory>
    >.internal(
      TodoCategories.new,
      name: r'todoCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoCategories = AutoDisposeAsyncNotifier<List<TodoCategory>>;
String _$todoItemsHash() => r'f82de6174cd485c6e14330a13b4a79ceb02a710d';

/// See also [TodoItems].
@ProviderFor(TodoItems)
final todoItemsProvider =
    AutoDisposeAsyncNotifierProvider<TodoItems, List<TodoItem>>.internal(
      TodoItems.new,
      name: r'todoItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoItems = AutoDisposeAsyncNotifier<List<TodoItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
