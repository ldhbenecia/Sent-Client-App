import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state.g.dart';

/// GoRouter의 refreshListenable로 연결.
/// notifyListeners() 호출 시 GoRouter가 redirect를 재실행함.
@Riverpod(keepAlive: true)
AuthStateNotifier authStateNotifier(Ref ref) => AuthStateNotifier();

class AuthStateNotifier extends ChangeNotifier {
  VoidCallback? _cleanupCallback;

  /// 로그아웃 시 실행할 cleanup (프로바이더 invalidate 등) 등록.
  /// app_router.dart에서 한 번만 세팅.
  void setCleanupCallback(VoidCallback cb) => _cleanupCallback = cb;

  /// 토큰 만료/로그아웃 → 상태 초기화 → GoRouter redirect 트리거
  void logout() {
    _cleanupCallback?.call();
    notifyListeners();
  }
}
