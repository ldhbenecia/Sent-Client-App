import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/theme/app_color_theme.dart';
import '../../domain/models/todo_category.dart';

// ══════════════════════════════════════════════════════════════════
// 카테고리 선택 시트
// ══════════════════════════════════════════════════════════════════
class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({
    super.key,
    required this.categories,
    required this.selectedId,
    this.onManage,
  });

  final List<TodoCategory> categories;
  final String? selectedId;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.26),
                  Colors.white.withValues(alpha: 0.14),
                ]
              : [
                  const Color(0xF2111111),
                  const Color(0xF50D0D0D),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.10),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
            child: Row(
              children: [
                Text(
                  l10n.categorySelect,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onManage != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onManage!();
                    },
                    child: Text(
                      '편집',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // "없음" 항목
          InkWell(
            onTap: () => Navigator.pop(context, ''),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.block_rounded,
                        size: 16, color: colors.textMuted),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.none,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  if (selectedId == null)
                    Icon(Icons.check_rounded,
                        size: 18, color: colors.textPrimary),
                ],
              ),
            ),
          ),
          Divider(height: 0.5, color: colors.border, indent: 20),
          // 카테고리 목록
          ...categories.map((cat) {
            final isSelected = cat.id == selectedId;
            return InkWell(
              onTap: () => Navigator.pop(context, cat.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(cat.icon, size: 16, color: cat.color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(Icons.check_rounded,
                          size: 18, color: colors.textPrimary),
                  ],
                ),
              ),
            );
          }),
          SafeArea(
            top: false,
            child: const SizedBox(height: 8),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
