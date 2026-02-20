import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/theme/app_colors.dart';

const _kDevMode = bool.fromEnvironment('DEV_MODE', defaultValue: false);

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SENT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
            onPressed: () => _onProfileTap(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: const _TodoBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.foreground,
        foregroundColor: AppColors.background,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Future<void> _onProfileTap(BuildContext context, WidgetRef ref) async {
    if (!_kDevMode) return;
    await ref.read(tokenStorageProvider).clearTokens();
    if (context.mounted) context.go('/auth/login');
  }
}

class _TodoBody extends StatelessWidget {
  const _TodoBody();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const months = ['1월','2월','3월','4월','5월','6월','7월','8월','9월','10월','11월','12월'];
    const days = ['일','월','화','수','목','금','토'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${now.year}년 ${months[now.month - 1]} ${now.day}일',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${days[now.weekday % 7]}요일',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          child: _EmptyState(
            icon: Icons.check_circle_outline_rounded,
            title: '할 일이 없습니다',
            subtitle: '아래 + 버튼으로\n첫 번째 할 일을 추가해보세요',
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 13,
                letterSpacing: -0.1,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
