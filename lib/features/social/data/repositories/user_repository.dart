import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/user_search_result.dart';

class UserRepository {
  const UserRepository(this._dio);

  final Dio _dio;

  // GET /api/v1/users/{id}
  Future<UserProfile> fetchProfile(String userId) async {
    try {
      final res = await _dio.get('/api/v1/users/$userId');
      final data = res.data['data'] as Map<String, dynamic>;
      return UserProfile(
        id: data['id'] as String,
        provider: data['provider'] as String,
        email: data['email'] as String,
        displayName: data['displayName'] as String,
        userCode: data['userCode'] as String,
        profileImageUrl: data['profileImageUrl'] as String?,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // GET /api/v1/users/search?code={userCode}
  Future<UserSearchResult?> searchByCode(String userCode) async {
    try {
      final res = await _dio.get(
        '/api/v1/users/search',
        queryParameters: {'code': userCode},
      );
      final data = res.data['data'] as Map<String, dynamic>;
      return UserSearchResult(
        userCode: data['userCode'] as String,
        displayName: data['displayName'] as String,
        profileImageUrl: data['profileImageUrl'] as String?,
      );
    } on DioException catch (e) {
      final mapped = mapDioException(e);
      if (mapped is NotFoundException) return null;
      throw mapped;
    }
  }
}
