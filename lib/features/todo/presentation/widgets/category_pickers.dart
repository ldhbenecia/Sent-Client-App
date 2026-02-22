import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../domain/models/todo_category.dart';

// ══════════════════════════════════════════════════════════════════
// 아이콘 그리드
// ══════════════════════════════════════════════════════════════════
class CategoryIconGrid extends StatelessWidget {
  const CategoryIconGrid({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final IconData selected;
  final ValueChanged<IconData> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: kCategoryIcons.length,
        itemBuilder: (context, index) {
          final icon = kCategoryIcons[index];
          final isSelected = icon == selected;
          return GestureDetector(
            onTap: () => onSelect(icon),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.foreground.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: AppColors.foreground.withOpacity(0.4),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 색상 선택기
// ══════════════════════════════════════════════════════════════════
class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final Color selected;
  final ValueChanged<Color> onSelect;

  static const _basicColors = AppColors.categoryPresets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _basicColors.map((color) {
              final isSelected = color == selected;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: _ColorDot(
                  color: color,
                  isSelected: isSelected,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.isSelected});

  final Color color;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: Colors.white, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
          : null,
    );
  }
}
