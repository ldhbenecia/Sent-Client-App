import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../../features/todo/presentation/pages/todo_edit_page.dart';
import '../../features/todo/presentation/pages/category_page.dart';
import '../../features/todo/presentation/pages/category_edit_page.dart';
import '../../features/todo/domain/models/todo_category.dart';
import '../../features/todo/domain/models/todo_item.dart';
import '../../features/memo/presentation/pages/memo_page.dart';
import '../../features/social/presentation/pages/social_page.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/theme/app_colors.dart';
import '../storage/token_storage.dart';

part 'app_router.g.dart';

const _kDevMode = bool.fromEnvironment('DEV_MODE', defaultValue: false);

@riverpod
GoRouter appRouter(Ref ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  return GoRouter(
    initialLocation: '/auth/login',
    redirect: (context, state) async {
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      try {
        if (!_kDevMode) {
          final token = await tokenStorage.getAccessToken();
          if (token == 'dev_access_token') {
            await tokenStorage.clearTokens();
            return '/auth/login';
          }
        }
        final hasToken = await tokenStorage.hasToken();
        if (!hasToken && !isAuthRoute) return '/auth/login';
        if (hasToken && isAuthRoute) return '/todo';
      } catch (_) {
        if (!isAuthRoute) return '/auth/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            _AnimatedBranchContainer(shell: shell, children: children),
        branches: [
          // ── Tab 0: Todo ──────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/todo',
                name: 'todo',
                builder: (context, state) => const TodoPage(),
                routes: [
                  GoRoute(
                    path: 'categories',
                    name: 'categories',
                    builder: (context, state) => const CategoryPage(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: 'category-create',
                        builder: (context, state) =>
                            const CategoryEditPage(category: null),
                      ),
                      GoRoute(
                        path: ':id/edit',
                        name: 'category-edit',
                        builder: (context, state) => CategoryEditPage(
                          category: state.extra as TodoCategory?,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'new',
                    name: 'todo-create',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      child: TodoEditPage(
                        initialDate: state.extra as DateTime?,
                      ),
                      transitionsBuilder:
                          (context, animation, secondary, child) =>
                              SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    name: 'todo-edit',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      child: TodoEditPage(todo: state.extra as TodoItem?),
                      transitionsBuilder:
                          (context, animation, secondary, child) =>
                              SlideTransition(
                        position: animation.drive(
                          Tween(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).chain(CurveTween(curve: Curves.easeOutCubic)),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ── Tab 1: Memo ──────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/memo',
                name: 'memo',
                builder: (context, state) => const MemoPage(),
              ),
            ],
          ),
          // ── Tab 2: Social ────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/social',
                name: 'social',
                builder: (context, state) => const SocialPage(),
              ),
            ],
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

// ── 탭 전환 애니메이션 컨테이너 ─────────────────────────────────────
class _AnimatedBranchContainer extends StatefulWidget {
  const _AnimatedBranchContainer({
    required this.shell,
    required this.children,
  });

  final StatefulNavigationShell shell;
  final List<Widget> children;

  @override
  State<_AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<_AnimatedBranchContainer> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.shell.currentIndex);
  }

  @override
  void didUpdateWidget(_AnimatedBranchContainer old) {
    super.didUpdateWidget(old);
    if (widget.shell.currentIndex != old.shell.currentIndex) {
      _controller.animateToPage(
        widget.shell.currentIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      physics: const NeverScrollableScrollPhysics(),
      children: widget.children,
    );
  }
}
