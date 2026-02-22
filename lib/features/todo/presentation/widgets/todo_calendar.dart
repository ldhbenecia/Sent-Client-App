import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../shared/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════
// 캘린더 날짜 셀 (숫자 + 점을 하나의 Column으로)
// ══════════════════════════════════════════════════════════════════
Widget buildTodoDayCell(
  DateTime day, {
  required bool isSelected,
  required bool isToday,
  required bool isOutside,
  required bool hasTodo,
}) {
  final textColor = isSelected
      ? AppColors.background
      : isOutside
          ? AppColors.textDisabled
          : AppColors.textPrimary;

  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: isSelected
              ? const BoxDecoration(
                  color: AppColors.foreground,
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
                    ? AppColors.textDisabled
                    : AppColors.textMuted)
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
      child: Row(
        children: [
          Text(
            '${focusedDay.year}년 ${focusedDay.month}월',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.textDisabled,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onPrev,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.chevron_left_rounded,
                  size: 20, color: AppColors.textMuted),
            ),
          ),
          GestureDetector(
            onTap: onNext,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
