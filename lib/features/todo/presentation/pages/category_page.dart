import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../providers/todo_provider.dart';
import '../../domain/models/todo_category.dart';
import 'category_edit_page.dart';

// ══════════════════════════════════════════════════════════════════
// CategoryPage — 카테고리 목록 관리
// ══════════════════════════════════════════════════════════════════
class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(todoCategoriesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: colors.textPrimary,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.categoryEdit,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: colors.textPrimary,
        backgroundColor: colors.card,
        onRefresh: () async => ref.invalidate(todoCategoriesProvider),
        child: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.toString().replaceAll('Exception: ', ''),
                      style: TextStyle(color: colors.textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => ref.invalidate(todoCategoriesProvider),
                      child: Text(
                        l10n.retry,
                        style: TextStyle(color: colors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (categories) => ListView(
            children: [
              // 새 카테고리 추가 버튼
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CategoryEditPage(category: null),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.circle_outlined,
                          size: 13,
                          color: colors.textDisabled,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.categoryNew,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors.secondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.border, width: 0.5),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(height: 0.5, thickness: 0.5, color: colors.border),

              // 카테고리 목록
              ...categories.map(
                (cat) => _CategoryListTile(
                  category: cat,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoryEditPage(category: cat),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({required this.category, required this.onTap});

  final TodoCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, size: 17, color: category.color),
            ),
            const SizedBox(width: 12),
            // 카테고리명
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: colors.textPrimary,
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
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
