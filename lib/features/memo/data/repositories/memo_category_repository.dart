import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/app_exception.dart';
import '../../../todo/domain/models/todo_category.dart'
    show iconToName, colorToHex;
import '../../domain/models/memo_category.dart';
import '../models/memo_dto.dart';

class MemoCategoryRepository {
  const MemoCategoryRepository(this._dio);

  final Dio _dio;

  // ── GET /api/v1/memos/categories ─────────────────────────────
  Future<List<MemoCategory>> fetchAll() async {
    try {
      final res = await _dio.get('/api/v1/memos/categories');
      final list = res.data['data'] as List;
      return list
          .map((e) =>
              MemoCategoryDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── POST /api/v1/memos/categories ────────────────────────────
  Future<MemoCategory> create({
    required String name,
    required IconData icon,
    required Color color,
  }) async {
    try {
      final res = await _dio.post(
        '/api/v1/memos/categories',
        data: {
          'name': name,
          'icon': iconToName(icon),
          'color': colorToHex(color),
        },
      );
      final id = (res.data['data']['id'] as int).toString();
      return MemoCategory(id: id, name: name, color: color, icon: icon);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── PATCH /api/v1/memos/categories/{id} ──────────────────────
  Future<MemoCategory> update(MemoCategory category) async {
    try {
      await _dio.patch(
        '/api/v1/memos/categories/${category.id}',
        data: {
          'name': category.name,
          'icon': iconToName(category.icon),
          'color': colorToHex(category.color),
        },
      );
      return category;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── DELETE /api/v1/memos/categories/{id} ─────────────────────
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/api/v1/memos/categories/$id');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
