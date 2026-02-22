import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
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
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
            child: Row(
              children: [
                const Text(
                  '카테고리 선택',
                  style: TextStyle(
                    color: AppColors.textPrimary,
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
                    child: const Text(
                      '편집',
                      style: TextStyle(
                        color: AppColors.textMuted,
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
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.block_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '없음',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  if (selectedId == null)
                    const Icon(Icons.check_rounded,
                        size: 18, color: AppColors.textPrimary),
                ],
              ),
            ),
          ),
          const Divider(height: 0.5, color: AppColors.border, indent: 20),
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
                        color: cat.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(cat.icon, size: 16, color: cat.color),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      cat.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(Icons.check_rounded,
                          size: 18, color: AppColors.textPrimary),
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
    );
  }
}
