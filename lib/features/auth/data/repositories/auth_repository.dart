import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';

class AuthRepository {
  const AuthRepository(this._dio);

  final Dio _dio;

  // POST /api/auth/logout
  // Authorization 헤더는 인터셉터가 자동 첨부
  // refresh_token은 Cookie로 전송
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dio.post(
        '/api/auth/logout',
        options: Options(
          headers: {'Cookie': 'refresh_token=$refreshToken'},
        ),
      );
    } on DioException catch (e) {
      // 로그아웃은 서버 오류여도 로컬 토큰은 삭제 → 예외 무시
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return; // 오프라인 상태에서도 로그아웃 허용
      }
      throw mapDioException(e);
    }
  }
}
