import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('로그인이 필요합니다.');
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class UnknownException extends AppException {
  const UnknownException() : super('알 수 없는 오류가 발생했습니다.');
}

AppException mapDioException(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout =>
      const NetworkException('네트워크 연결을 확인해주세요.'),
    DioExceptionType.badResponse => switch (e.response?.statusCode) {
        401 => const UnauthorizedException(),
        404 => NotFoundException(
            e.response?.data?['message'] ?? '요청한 정보를 찾을 수 없습니다.',
          ),
        _ => ServerException(
            e.response?.data?['message'] ?? '서버 오류가 발생했습니다.',
          ),
      },
    DioExceptionType.connectionError => const NetworkException('서버에 연결할 수 없습니다.'),
    _ => const UnknownException(),
  };
}
