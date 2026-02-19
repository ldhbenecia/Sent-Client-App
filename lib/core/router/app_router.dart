import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../shared/widgets/main_shell.dart';
import '../storage/token_storage.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  return GoRouter(
    initialLocation: '/todo',
    redirect: (context, state) async {
      final hasToken = await tokenStorage.hasToken();
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!hasToken && !isAuthRoute) {
        return '/auth/login';
      }
      if (hasToken && isAuthRoute) {
        return '/todo';
      }
      return null;
    },
    routes: [
      // 인증 라우트
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpPage(),
      ),
      // 메인 쉘 (바텀 네비게이션)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/todo',
            name: 'todo',
            builder: (context, state) => const TodoPage(),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatListPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('페이지를 찾을 수 없습니다: ${state.error}')),
    ),
  );
}
