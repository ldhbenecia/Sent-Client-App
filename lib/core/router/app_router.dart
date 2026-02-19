import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../../features/memo/presentation/pages/memo_page.dart';
import '../../features/social/presentation/pages/social_page.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/theme/app_colors.dart';
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

      if (!hasToken && !isAuthRoute) return '/auth/login';
      if (hasToken && isAuthRoute) return '/todo';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/todo',
            name: 'todo',
            builder: (context, state) => const TodoPage(),
          ),
          GoRoute(
            path: '/memo',
            name: 'memo',
            builder: (context, state) => const MemoPage(),
          ),
          GoRoute(
            path: '/social',
            name: 'social',
            builder: (context, state) => const SocialPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '페이지를 찾을 수 없습니다',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    ),
  );
}
