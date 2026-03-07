import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/todo_statistics.dart';

class TodoStatisticsRepository {
  const TodoStatisticsRepository(this._dio);

  final Dio _dio;

  // GET /api/v1/todos/statistics?year=&month=
  Future<TodoStatistics> fetchStatistics(int year, int month) async {
    try {
      final res = await _dio.get(
        '/api/v1/todos/statistics',
        queryParameters: {'year': year, 'month': month},
      );
      return TodoStatistics.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

final todoStatisticsRepositoryProvider =
    Provider<TodoStatisticsRepository>((ref) {
  return TodoStatisticsRepository(ref.watch(dioProvider));
});
