import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/theme/app_color_theme.dart';
import '../../../../../shared/utils/haptics.dart';
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
    final colors = context.colors;
    return InkWell(
      onTap: () { Haptics.light(); onEdit(); },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () { Haptics.light(); onToggle(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isDone ? colors.textDisabled : Colors.transparent,
                  border: Border.all(
                    color: item.isDone
                        ? colors.textDisabled
                        : colors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: item.isDone
                    ? Icon(Icons.check_rounded,
                        size: 13, color: colors.background)
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
                          ? colors.textDisabled
                          : colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      decoration:
                          item.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: colors.textDisabled,
                    ),
                  ),
                  if (item.time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(item.time!),
                      style: TextStyle(
                        color: colors.textMuted,
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
    final colors = context.colors;
    return GestureDetector(
      onTap: () => _showOptions(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(Icons.more_horiz_rounded,
            size: 18, color: colors.textMuted),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 40),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _OptionTile(
              label: l10n.edit,
              icon: Icons.edit_rounded,
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            Divider(
                height: 0.5,
                color: colors.border,
                indent: 16,
                endIndent: 16),
            _OptionTile(
              label: l10n.delete,
              icon: Icons.delete_outline_rounded,
              color: colors.destructiveRed,
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
    final colors = context.colors;
    final c = color ?? colors.textPrimary;
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
