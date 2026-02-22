import 'package:flutter/material.dart';
import '../../domain/models/todo_item.dart';
import 'category_dto.dart';

/// 서버 응답 DTO — GET /api/v1/todos/month, GET /api/v1/todos/{id}
class TodoDto {
  final int id;
  final String title;
  final CategoryDto? category;
  final String scheduledDate;   // "2025-06-15"
  final String? scheduledTime;  // "19:00:00"
  final bool isDone;

  const TodoDto({
    required this.id,
    required this.title,
    this.category,
    required this.scheduledDate,
    this.scheduledTime,
    required this.isDone,
  });

  factory TodoDto.fromJson(Map<String, dynamic> json) => TodoDto(
        id: json['id'] as int,
        title: json['title'] as String,
        category: json['category'] != null
            ? CategoryDto.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        scheduledDate: json['scheduledDate'] as String,
        scheduledTime: json['scheduledTime'] as String?,
        isDone: json['isDone'] as bool,
      );

  TodoItem toDomain() => TodoItem(
        id: id.toString(),
        title: title,
        isDone: isDone,
        categoryId: category?.id.toString(),
        date: _parseDate(scheduledDate),
        time: scheduledTime != null ? _parseTime(scheduledTime!) : null,
      );

  static DateTime _parseDate(String s) {
    final parts = s.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
