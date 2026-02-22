import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════
// 햄버거 메뉴 카드
// ══════════════════════════════════════════════════════════════════
class TodoMenuCard extends StatelessWidget {
  const TodoMenuCard({
    super.key,
    required this.onCategoryTap,
    this.onDevLogout,
  });

  final VoidCallback onCategoryTap;
  final VoidCallback? onDevLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xF00F0F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            child: Row(
              children: [
                const Text(
                  'Todos',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, color: AppColors.border),
          _MenuRow(label: 'View', onTap: () => Navigator.of(context).pop()),
          _MenuRow(label: 'Category', onTap: onCategoryTap),
          _MenuRow(label: 'My', onTap: () => Navigator.of(context).pop()),
          _MenuRow(label: 'Alarm', onTap: () => Navigator.of(context).pop()),
          if (onDevLogout != null) ...[
            const Divider(height: 0.5, color: AppColors.border),
            _MenuRow(
              label: 'DEV Logout',
              color: AppColors.destructiveRed,
              onTap: onDevLogout!,
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Text(
          label,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
