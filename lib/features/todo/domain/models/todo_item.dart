import 'package:flutter/material.dart';

class TodoItem {
  final String id;
  final String title;
  final bool isDone;
  final String? categoryId;
  final DateTime date;
  final TimeOfDay? time;

  const TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    this.categoryId,
    required this.date,
    this.time,
  });

  TodoItem toggleDone() => TodoItem(
        id: id,
        title: title,
        isDone: !isDone,
        categoryId: categoryId,
        date: date,
        time: time,
      );

  TodoItem copyWith({
    String? title,
    bool? isDone,
    String? categoryId,
    DateTime? date,
    TimeOfDay? time,
    bool clearCategory = false,
    bool clearTime = false,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      date: date ?? this.date,
      time: clearTime ? null : (time ?? this.time),
    );
  }

  @override
  bool operator ==(Object other) => other is TodoItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
