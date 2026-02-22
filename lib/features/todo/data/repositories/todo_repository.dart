import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/models/todo_item.dart';
import '../models/todo_dto.dart';

class TodoRepository {
  const TodoRepository(this._dio);

  final Dio _dio;

  // ── GET /api/v1/todos/month ───────────────────────────────────
  Future<List<TodoItem>> fetchByMonth(int year, int month) async {
    try {
      final res = await _dio.get(
        '/api/v1/todos/month',
        queryParameters: {'year': year, 'month': month},
      );
      final list = res.data['data'] as List;
      return list
          .map((e) => TodoDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── POST /api/v1/todos ────────────────────────────────────────
  /// 서버는 { id: Long } 만 반환 → 입력값으로 도메인 객체 조립
  Future<TodoItem> create({
    required String title,
    required DateTime date,
    String? categoryId,
    TimeOfDay? time,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'scheduledDate': _formatDate(date),
        if (categoryId != null) 'categoryId': int.parse(categoryId),
        if (time != null) 'scheduledTime': _formatTime(time),
      };

      final res = await _dio.post('/api/v1/todos', data: body);
      final id = (res.data['data']['id'] as int).toString();

      return TodoItem(
        id: id,
        title: title,
        categoryId: categoryId,
        date: date,
        time: time,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── PATCH /api/v1/todos/{id} ──────────────────────────────────
  Future<TodoItem> update(TodoItem item) async {
    try {
      final body = <String, dynamic>{
        'title': item.title,
        'scheduledDate': _formatDate(item.date),
        'categoryId': item.categoryId != null ? int.parse(item.categoryId!) : null,
        'scheduledTime': item.time != null ? _formatTime(item.time!) : null,
      };

      await _dio.patch('/api/v1/todos/${item.id}', data: body);
      return item; // 서버는 id만 반환 → 입력값 그대로 사용
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── PATCH /api/v1/todos/{id}/done ─────────────────────────────
  Future<void> markDone(String id, bool done) async {
    try {
      await _dio.patch(
        '/api/v1/todos/$id/done',
        queryParameters: {'done': done},
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── DELETE /api/v1/todos/{id} ────────────────────────────────
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/api/v1/todos/$id');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── 날짜/시간 포맷 헬퍼 ─────────────────────────────────────────
  static String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}
