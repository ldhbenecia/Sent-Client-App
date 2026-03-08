import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/settings/presentation/pages/preferences_page.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/todo/presentation/providers/todo_provider.dart';
import '../../shared/widgets/main_shell.dart';
import '../../shared/theme/app_color_theme.dart';
import '../auth/auth_state.dart';
import '../storage/token_storage.dart';
import 'route_transitions.dart';
import 'shell_branches.dart';

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
        if (hasToken && isAuthRoute) return '/home';
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
              slideRightFadeTransition(animation, child),
        ),
      ),
      StatefulShellRoute(
        builder: (context, state, shell) => MainShell(
          navigationShell: shell,
          currentPath: state.uri.path,
        ),
        navigatorContainerBuilder: (context, shell, children) =>
            _AnimatedBranchContainer(shell: shell, children: children),
        branches: buildMainShellBranches(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
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
class _AnimatedBranchContainer extends ConsumerStatefulWidget {
  const _AnimatedBranchContainer({required this.shell, required this.children});

  final StatefulNavigationShell shell;
  final List<Widget> children;

  @override
  ConsumerState<_AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState
    extends ConsumerState<_AnimatedBranchContainer> {
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
      // build 중 provider 수정 금지 → 다음 프레임으로 지연
      final newIndex = widget.shell.currentIndex;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(currentBranchIndexProvider.notifier).set(newIndex);
        }
      });
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
