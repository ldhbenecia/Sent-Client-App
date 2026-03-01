import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/theme/app_color_theme.dart';

// ══════════════════════════════════════════════════════════════════
// 캘린더 날짜 셀 (숫자 + 점을 하나의 Column으로)
// ══════════════════════════════════════════════════════════════════
Widget buildTodoDayCell(
  BuildContext context,
  DateTime day, {
  required bool isSelected,
  required bool isToday,
  required bool isOutside,
  required bool hasTodo,
}) {
  final colors = context.colors;
  final textColor = isSelected
      ? colors.background
      : isOutside
          ? colors.textDisabled
          : colors.textPrimary;

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
                  color: colors.foreground,
                  shape: BoxShape.circle,
                )
              : null,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: hasTodo
                ? (isSelected
                    ? colors.textDisabled
                    : colors.textMuted)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════
// 캘린더 커스텀 헤더
// ══════════════════════════════════════════════════════════════════
class TodoCalendarHeader extends StatelessWidget {
  const TodoCalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onPrev,
    required this.onNext,
    this.isLoading = false,
  });

  final DateTime focusedDay;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      child: Row(
        children: [
          Text(
            DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(focusedDay),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          if (isLoading) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: colors.textDisabled,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onPrev,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.chevron_left_rounded,
                  size: 20, color: colors.textMuted),
            ),
          ),
          GestureDetector(
            onTap: onNext,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.chevron_right_rounded,
                  size: 20, color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
