import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/models/user_search_result.dart';

class UserRepository {
  const UserRepository(this._dio);

  final Dio _dio;

  // GET /api/v1/users/search?provider=&email=
  // provider를 모르는 경우를 위해 google → naver → kakao 순서로 시도
  Future<UserSearchResult?> searchByEmail(String email) async {
    for (final provider in ['google', 'naver', 'kakao']) {
      try {
        final res = await _dio.get(
          '/api/v1/users/search',
          queryParameters: {'provider': provider, 'email': email},
        );
        final data = res.data['data'] as Map<String, dynamic>;
        return UserSearchResult(
          email: data['email'] as String,
          displayName: data['displayName'] as String,
          profileImageUrl: data['profileImageUrl'] as String?,
        );
      } on DioException catch (e) {
        final mapped = mapDioException(e);
        if (mapped is NotFoundException) continue; // 다음 provider 시도
        throw mapped;
      }
    }
    return null; // 모든 provider에서 찾지 못함
  }
}
