import 'package:dio/dio.dart';

class FcmTokenRepository {
  FcmTokenRepository(this._dio);
  final Dio _dio;

  /// 서버에 FCM 토큰 등록/갱신
  Future<void> registerToken(String token) async {
    await _dio.put('/api/v1/fcm/token', data: {
      'token': token,
      'deviceType': 'IOS',
    });
  }

  /// 로그아웃 시 서버에서 토큰 삭제
  Future<void> unregisterToken(String token) async {
    await _dio.delete('/api/v1/fcm/token', data: {'token': token});
  }
}
