import 'package:flutter/material.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../domain/models/memo_item.dart';

class MemoTile extends StatelessWidget {
  const MemoTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MemoItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cat = item.category;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 배지
            if (cat != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 11, color: cat.color),
                    const SizedBox(width: 4),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: cat.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],

            // 제목
            Text(
              item.title,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // 내용 미리보기
            if (item.content != null && item.content!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                item.content!,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // 태그
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: item.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: colors.border, width: 0.5),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        color: colors.textDisabled,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
