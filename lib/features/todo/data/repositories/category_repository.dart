import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/models/todo_category.dart';
import '../models/category_dto.dart';

class CategoryRepository {
  const CategoryRepository(this._dio);

  final Dio _dio;

  // ── GET /api/v1/categories ────────────────────────────────────
  Future<List<TodoCategory>> fetchAll() async {
    try {
      final res = await _dio.get('/api/v1/categories');
      final list = res.data['data'] as List;
      return list
          .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── POST /api/v1/categories ───────────────────────────────────
  /// 서버는 { id: Long } 만 반환 → 입력값으로 도메인 객체 조립
  Future<TodoCategory> create({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    try {
      final res = await _dio.post(
        '/api/v1/categories',
        data: {
          'name': name,
          'icon': iconToName(icon),
          'color': colorToHex(color),
        },
      );
      final id = (res.data['data']['id'] as int).toString();
      return TodoCategory(id: id, name: name, color: color, icon: icon);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── PATCH /api/v1/categories/{id} ─────────────────────────────
  Future<TodoCategory> update(TodoCategory category) async {
    try {
      await _dio.patch(
        '/api/v1/categories/${category.id}',
        data: {
          'name': category.name,
          'icon': iconToName(category.icon),
          'color': colorToHex(category.color),
        },
      );
      return category; // 서버는 id만 반환 → 입력값 그대로 사용
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── DELETE /api/v1/categories/{id} ───────────────────────────
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/api/v1/categories/$id');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
