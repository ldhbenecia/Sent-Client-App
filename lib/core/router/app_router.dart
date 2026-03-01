import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/settings/presentation/pages/preferences_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import '../../features/todo/presentation/pages/todo_edit_page.dart';
import '../../features/todo/presentation/pages/category_page.dart';
import '../../features/todo/presentation/pages/category_edit_page.dart';
import '../../features/todo/domain/models/todo_category.dart';
import '../../features/todo/domain/models/todo_item.dart';
import '../../features/memo/presentation/pages/memo_page.dart';
import '../../features/social/presentation/pages/social_page.dart';
import '../../features/social/presentation/pages/chat_page.dart';
import '../../features/ledger/presentation/pages/ledger_page.dart';
import '../../features/ledger/presentation/pages/ledger_entry_edit_page.dart';
import '../../features/ledger/presentation/pages/ledger_category_page.dart';
import '../../features/ledger/presentation/pages/ledger_category_edit_page.dart';
import '../../features/ledger/domain/models/ledger_entry.dart';
import '../../features/ledger/domain/models/ledger_category.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/theme/app_color_theme.dart';
import '../storage/token_storage.dart';
import '../../features/todo/presentation/providers/todo_provider.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final authNotifier = ref.watch(authStateNotifierProvider);

  // 로그아웃 시 UI 상태만 초기화 (날짜 → 오늘로 리셋)
  // 데이터 프로바이더(todoItems 등)는 로그인 시점에 invalidate — 여기서 하면
  // StatefulShellBranch가 TodoPage를 살려두기 때문에 토큰 없이 즉시 rebuild → 401 에러 상태 고정됨
  authNotifier.setCleanupCallback(() {
    ref.invalidate(selectedDateProvider);
    ref.invalidate(focusedMonthProvider);
  });

  return GoRouter(
    initialLocation: '/auth/login',
    // authNotifier가 logout()을 호출하면 redirect 재실행 → 토큰 없으면 로그인으로
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      try {
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
      GoRoute(
        path: '/preferences',
        name: 'preferences',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PreferencesPage(),
          transitionsBuilder: (context, animation, secondary, child) =>
              SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          ),
        ),
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
          // ── Tab 1: Ledger ─────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/ledger',
                name: 'ledger',
                builder: (context, state) => const LedgerPage(),
                routes: [
                  GoRoute(
                    path: 'categories',
                    name: 'ledger-categories',
                    builder: (context, state) =>
                        const LedgerCategoryPage(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: 'ledger-category-create',
                        builder: (context, state) =>
                            const LedgerCategoryEditPage(category: null),
                      ),
                      GoRoute(
                        path: ':id/edit',
                        name: 'ledger-category-edit',
                        builder: (context, state) => LedgerCategoryEditPage(
                          category: state.extra as LedgerCategory?,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'new',
                    name: 'ledger-create',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      child: const LedgerEntryEditPage(),
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
                    name: 'ledger-edit',
                    pageBuilder: (context, state) => CustomTransitionPage(
                      child: LedgerEntryEditPage(
                          entry: state.extra as LedgerEntry?),
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
          // ── Tab 2: Social ────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/social',
                name: 'social',
                builder: (context, state) => const SocialPage(),
                routes: [
                  GoRoute(
                    path: 'chat',
                    name: 'social-chat',
                    builder: (context, state) {
                      final extra =
                          state.extra as Map<String, dynamic>;
                      return ChatPage(
                        opponentId: extra['opponentId'] as String,
                        friendName: extra['friendName'] as String,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // ── Tab 3: Memo ──────────────────────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/memo',
                name: 'memo',
                builder: (context, state) => const MemoPage(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Text(
          '페이지를 찾을 수 없습니다',
          style: TextStyle(color: context.colors.textSecondary),
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
