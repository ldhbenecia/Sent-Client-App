import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../../domain/models/todo_category.dart';

// ══════════════════════════════════════════════════════════════════
// CategoryPage — 카테고리 목록 관리
// ══════════════════════════════════════════════════════════════════
class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(todoCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textPrimary, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '카테고리 편집',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.toString().replaceAll('Exception: ', ''),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(todoCategoriesProvider),
                child: const Text('다시 시도',
                    style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
          ),
        ),
        data: (categories) => ListView(
          children: [
            // 새 카테고리 추가 버튼
            InkWell(
              onTap: () => context.push('/todo/categories/new'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.circle_outlined,
                          size: 13, color: AppColors.textDisabled),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '새로운 카테고리',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.border, width: 0.5),
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(
                height: 0.5, thickness: 0.5, color: AppColors.border),

            // 카테고리 목록
            ...categories.map((cat) => _CategoryListTile(
                  category: cat,
                  onTap: () => context.push(
                    '/todo/categories/${cat.id}/edit',
                    extra: cat,
                  ),
                )),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.category,
    required this.onTap,
  });

  final TodoCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // 아이콘 컨테이너
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, size: 17, color: category.color),
            ),
            const SizedBox(width: 12),
            // 카테고리명
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // 색상 점
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}
