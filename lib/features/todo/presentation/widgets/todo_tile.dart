import 'package:flutter/material.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../domain/models/todo_item.dart';

// ══════════════════════════════════════════════════════════════════
// 투두 아이템 타일
// ══════════════════════════════════════════════════════════════════
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isDone ? AppColors.textDisabled : Colors.transparent,
                  border: Border.all(
                    color: item.isDone
                        ? AppColors.textDisabled
                        : AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: item.isDone
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: AppColors.background)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: item.isDone
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.textDisabled,
                    ),
                  ),
                  if (item.time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(item.time!),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _MoreButton(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// ══════════════════════════════════════════════════════════════════
// ... 더보기 버튼
// ══════════════════════════════════════════════════════════════════
class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      behavior: HitTestBehavior.opaque,
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(Icons.more_horiz_rounded,
            size: 18, color: AppColors.textMuted),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 40),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              label: '수정',
              icon: Icons.edit_rounded,
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            const Divider(
                height: 0.5,
                color: AppColors.border,
                indent: 16,
                endIndent: 16),
            _OptionTile(
              label: '삭제',
              icon: Icons.delete_outline_rounded,
              color: AppColors.destructiveRed,
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: c, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
