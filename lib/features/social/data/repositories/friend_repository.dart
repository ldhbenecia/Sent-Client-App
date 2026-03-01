import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../domain/models/friend.dart';
import '../models/friend_dto.dart';

class FriendRepository {
  const FriendRepository(this._dio);

  final Dio _dio;

  // GET /api/v1/friends
  Future<List<Friend>> fetchAll() async {
    try {
      final res = await _dio.get('/api/v1/friends');
      final list = res.data['data'] as List;
      return list
          .map((e) => FriendDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // GET /api/v1/friends/requests
  Future<List<FriendRequest>> fetchPendingRequests() async {
    try {
      final res = await _dio.get('/api/v1/friends/requests');
      final list = res.data['data'] as List;
      return list
          .map((e) =>
              FriendRequestDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // POST /api/v1/friends — body: { receiverCode: String }
  Future<void> addFriend(String receiverCode) async {
    try {
      await _dio.post(
        '/api/v1/friends',
        data: {'receiverCode': receiverCode},
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // POST /api/v1/friends/{id}/accept
  Future<void> acceptRequest(int requestId) async {
    try {
      await _dio.post('/api/v1/friends/$requestId/accept');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // POST /api/v1/friends/{id}/reject
  Future<void> rejectRequest(int requestId) async {
    try {
      await _dio.post('/api/v1/friends/$requestId/reject');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  // DELETE /api/v1/friends/{friendId}
  Future<void> deleteFriend(int friendId) async {
    try {
      await _dio.delete('/api/v1/friends/$friendId');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
