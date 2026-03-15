import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/models/memo_item.dart';
import '../models/memo_dto.dart';

class MemoRepository {
  const MemoRepository(this._dio);

  final Dio _dio;

  // ── GET /api/v1/memos ────────────────────────────────────────
  Future<List<MemoItem>> fetchAll() async {
    try {
      final res = await _dio.get('/api/v1/memos');
      final list = res.data['data'] as List;
      return list
          .map((e) =>
              MemoItemDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── POST /api/v1/memos ───────────────────────────────────────
  Future<String> create({
    required String title,
    String? content,
    String? categoryId,
    List<String> tags = const [],
  }) async {
    try {
      final res = await _dio.post(
        '/api/v1/memos',
        data: {
          'title': title,
          if (content != null) 'content': content,
          if (categoryId != null) 'categoryId': int.parse(categoryId),
          if (tags.isNotEmpty) 'tags': tags,
        },
      );
      return (res.data['data']['id'] as int).toString();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── PATCH /api/v1/memos/{id} ─────────────────────────────────
  Future<void> update(MemoItem item, {required bool categoryIdUpdated}) async {
    try {
      await _dio.patch(
        '/api/v1/memos/${item.id}',
        data: {
          'title': item.title,
          if (item.content != null) 'content': item.content,
          'categoryId': item.category != null
              ? int.parse(item.category!.id)
              : null,
          'categoryIdUpdated': categoryIdUpdated,
          'tags': item.tags,
        },
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // ── DELETE /api/v1/memos/{id} ────────────────────────────────
  Future<void> delete(String id) async {
    try {
      await _dio.delete('/api/v1/memos/$id');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
