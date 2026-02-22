import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/token_storage.dart';

part 'api_client.g.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final tokenStorage = ref.read(tokenStorageProvider);

  // 요청 인터셉터: Access Token 자동 첨부
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401: 토큰 만료 → Refresh Token으로 재발급
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken(dio, tokenStorage);
          if (refreshed) {
            final retryRequest = error.requestOptions;
            final newToken = await tokenStorage.getAccessToken();
            retryRequest.headers['Authorization'] = 'Bearer $newToken';
            try {
              final response = await dio.fetch(retryRequest);
              return handler.resolve(response);
            } catch (e) {
              return handler.reject(error);
            }
          }
        }
        handler.next(error);
      },
    ),
  );

  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );

  return dio;
}

Future<bool> _refreshToken(Dio dio, TokenStorage tokenStorage) async {
  try {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    // 인터셉터 없는 별도 Dio로 호출 → 401 시 재귀 루프 방지
    // refresh_token은 쿠키로 전송 (서버가 @CookieValue로 읽음)
    final cleanDio = Dio(BaseOptions(
      baseUrl: dio.options.baseUrl,
      connectTimeout: dio.options.connectTimeout,
      receiveTimeout: dio.options.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'refresh_token=$refreshToken',
      },
    ));

    final response = await cleanDio.post('/api/auth/reissue');

    // ApiResponse<String> → 새 access token은 data 필드에
    final newAccessToken = response.data['data'] as String;
    await tokenStorage.saveTokens(
      accessToken: newAccessToken,
      refreshToken: refreshToken,
    );
    return true;
  } catch (e) {
    // 네트워크 오류는 토큰 유지, 인증 오류(4xx)만 토큰 삭제
    if (e is DioException && e.response != null) {
      await tokenStorage.clearTokens();
    }
    return false;
  }
}
