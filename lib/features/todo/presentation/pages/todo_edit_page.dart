import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_picker_sheet.dart';
import '../../domain/models/todo_item.dart';
import '../../domain/models/todo_category.dart';

// ══════════════════════════════════════════════════════════════════
// TodoEditPage — 투두 생성/수정
// ══════════════════════════════════════════════════════════════════
class TodoEditPage extends ConsumerStatefulWidget {
  const TodoEditPage({super.key, this.todo, this.initialDate});

  final TodoItem? todo;
  final DateTime? initialDate;

  @override
  ConsumerState<TodoEditPage> createState() => _TodoEditPageState();
}

class _TodoEditPageState extends ConsumerState<TodoEditPage> {
  late final TextEditingController _titleCtrl;
  late DateTime _date;
  String? _categoryId;
  TimeOfDay? _time;
  int? _alarmMinutes; // null = 없음

  bool _showTimePicker = false;
  bool _showAlarmPicker = false;
  bool _isSaving = false;

  bool get _isEdit => widget.todo != null;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    _titleCtrl = TextEditingController(text: todo?.title ?? '');
    _date = todo?.date ?? widget.initialDate ?? ref.read(selectedDateProvider);
    _categoryId = todo?.categoryId;
    _time = todo?.time;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return '${d.year}년 ${months[d.month - 1]} ${d.day}일';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _alarmLabel(int? minutes, AppLocalizations l10n) {
    return switch (minutes) {
      null => l10n.none,
      5    => l10n.alarmBefore5min,
      10   => l10n.alarmBefore10min,
      15   => l10n.alarmBefore15min,
      30   => l10n.alarmBefore30min,
      60   => l10n.alarmBefore1hour,
      _    => l10n.none,
    };
  }

  void _toggleTimePicker() {
    setState(() {
      _showTimePicker = !_showTimePicker;
      if (_showTimePicker) _showAlarmPicker = false;
    });
  }

  void _toggleAlarmPicker() {
    setState(() {
      _showAlarmPicker = !_showAlarmPicker;
      if (_showAlarmPicker) _showTimePicker = false;
    });
  }

  // ── 저장 ──────────────────────────────────────────────────────
  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(todoItemsProvider.notifier);

      if (_isEdit) {
        await notifier.edit(widget.todo!.copyWith(
          title: title,
          categoryId: _categoryId,
          date: _date,
          time: _time,
          clearCategory: _categoryId == null,
          clearTime: _time == null,
        ));
      } else {
        await notifier.add(TodoItem(
          id: '',
          title: title,
          categoryId: _categoryId,
          date: _date,
          time: _time,
        ));
      }

      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      final colors = context.colors;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: colors.destructiveRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── 카테고리 선택 시트 ─────────────────────────────────────────
  Future<void> _pickCategory() async {
    final categories = ref.read(todoCategoriesProvider).valueOrNull ?? [];
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CategoryPickerSheet(
        categories: categories,
        selectedId: _categoryId,
        onManage: () => context.push('/todo/categories'),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _categoryId = result.isEmpty ? null : result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final categories = ref.watch(todoCategoriesProvider).valueOrNull ?? [];
    final selectedCat = _categoryId != null
        ? categories.firstWhere(
            (c) => c.id == _categoryId,
            orElse: () => TodoCategory(
              id: _categoryId!,
              name: '알 수 없음',
              color: colors.textMuted,
              icon: Icons.circle_outlined,
            ),
          )
        : null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded,
              color: colors.textPrimary, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _formatDate(_date),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _titleCtrl.text.trim().isNotEmpty ? _save : null,
            child: Text(
              l10n.register,
              style: TextStyle(
                color: _titleCtrl.text.trim().isNotEmpty
                    ? colors.textPrimary
                    : colors.textDisabled,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Divider(height: 0.5, color: colors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // 할 일 입력
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _titleCtrl,
                    autofocus: !_isEdit,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.todoContentHint,
                      hintStyle: TextStyle(
                        color: colors.textPlaceholder,
                        fontSize: 17,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                      height: 0.5, thickness: 0.5, color: colors.border),
                ),

                // 카테고리
                _FormRow(
                  label: l10n.todoCategory,
                  onTap: _pickCategory,
                  trailing: selectedCat != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: selectedCat.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selectedCat.name,
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          l10n.none,
                          style: TextStyle(
                            color: colors.textDisabled,
                            fontSize: 14,
                          ),
                        ),
                ),

                // 시간 선택 (드럼 피커 토글)
                TapRegion(
                  groupId: 'timePicker',
                  child: _FormRow(
                    label: l10n.todoTime,
                    onTap: _toggleTimePicker,
                    isExpanded: _showTimePicker,
                    trailing: Text(
                      _time != null ? _formatTime(_time!) : l10n.none,
                      style: TextStyle(
                        color: _time != null
                            ? colors.textMuted
                            : colors.textDisabled,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // 인라인 시간 드럼 피커
                if (_showTimePicker)
                  TapRegion(
                    groupId: 'timePicker',
                    onTapOutside: (_) =>
                        setState(() => _showTimePicker = false),
                    child: _InlineTimePicker(
                      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
                      onConfirm: (t) =>
                          setState(() { _time = t; _showTimePicker = false; }),
                      onReset: () =>
                          setState(() { _time = null; _showTimePicker = false; }),
                    ),
                  ),

                // 알림 (토글)
                TapRegion(
                  groupId: 'alarmPicker',
                  child: _FormRow(
                    label: l10n.todoNotification,
                    onTap: _toggleAlarmPicker,
                    isExpanded: _showAlarmPicker,
                    trailing: Text(
                      _alarmLabel(_alarmMinutes, l10n),
                      style: TextStyle(
                        color: _alarmMinutes != null
                            ? colors.textMuted
                            : colors.textDisabled,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // 인라인 알림 옵션 피커
                if (_showAlarmPicker)
                  TapRegion(
                    groupId: 'alarmPicker',
                    onTapOutside: (_) =>
                        setState(() => _showAlarmPicker = false),
                    child: _InlineAlarmOptions(
                      selected: _alarmMinutes,
                      onSelect: (v) =>
                          setState(() { _alarmMinutes = v; _showAlarmPicker = false; }),
                    ),
                  ),
              ],
            ),
          ),

          // 삭제 버튼 (수정 모드만)
          if (_isEdit) ...[
            Divider(height: 0.5, color: colors.border),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: colors.card,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Text(
                            l10n.delete,
                            style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w600),
                          ),
                          content: Text(
                            l10n.deleteConfirm,
                            style: TextStyle(
                                color: colors.textSecondary, fontSize: 15),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.cancel,
                                  style: TextStyle(color: colors.textMuted)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.delete,
                                  style: TextStyle(
                                      color: colors.destructiveRed)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true || !context.mounted) return;
                      ref
                          .read(todoItemsProvider.notifier)
                          .remove(widget.todo!.id);
                      context.pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          colors.destructiveRed.withValues(alpha: 0.12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.delete,
                      style: TextStyle(
                        color: colors.destructiveRed,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else
            const SafeArea(top: false, child: SizedBox(height: 8)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 폼 행 위젯
// ══════════════════════════════════════════════════════════════════
class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.label,
    this.trailing,
    this.onTap,
    this.isExpanded = false,
  });

  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            ?trailing,
            if (onTap != null) ...[
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.chevron_right_rounded,
                    size: 18, color: colors.textDisabled),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 인라인 드럼롤 시간 피커
// ══════════════════════════════════════════════════════════════════
class _InlineTimePicker extends StatefulWidget {
  const _InlineTimePicker({
    required this.initialTime,
    required this.onConfirm,
    required this.onReset,
  });

  final TimeOfDay initialTime;
  final void Function(TimeOfDay) onConfirm;
  final VoidCallback onReset;

  @override
  State<_InlineTimePicker> createState() => _InlineTimePickerState();
}

class _InlineTimePickerState extends State<_InlineTimePicker> {
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    const itemExtent = 44.0;
    const pickerHeight = 220.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.09),
                    Colors.white.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.10),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: pickerHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 선택 하이라이트 밴드
                  Container(
                    height: itemExtent,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // 시/분 스크롤
                  Row(
                    children: [
                      // 시
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _hourCtrl,
                          itemExtent: itemExtent,
                          physics: const FixedExtentScrollPhysics(),
                          overAndUnderCenterOpacity: 0.3,
                          perspective: 0.003,
                          onSelectedItemChanged: (i) =>
                              setState(() => _hour = i),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 24,
                            builder: (_, i) => Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 구분자
                      Text(
                        ':',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // 분
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _minCtrl,
                          itemExtent: itemExtent,
                          physics: const FixedExtentScrollPhysics(),
                          overAndUnderCenterOpacity: 0.3,
                          perspective: 0.003,
                          onSelectedItemChanged: (i) =>
                              setState(() => _minute = i),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 60,
                            builder: (_, i) => Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 버튼 영역
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
              child: Row(
                children: [
                  TextButton(
                    onPressed: widget.onReset,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textMuted,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: Text(l10n.reset,
                        style: const TextStyle(fontSize: 14)),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => widget
                        .onConfirm(TimeOfDay(hour: _hour, minute: _minute)),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0A84FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 인라인 알림 옵션 피커
// ══════════════════════════════════════════════════════════════════
class _InlineAlarmOptions extends StatelessWidget {
  const _InlineAlarmOptions({required this.selected, required this.onSelect});

  final int? selected;
  final void Function(int?) onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    final options = <(int?, String)>[
      (null, l10n.none),
      (5, l10n.alarmBefore5min),
      (10, l10n.alarmBefore10min),
      (15, l10n.alarmBefore15min),
      (30, l10n.alarmBefore30min),
      (60, l10n.alarmBefore1hour),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.09),
                    Colors.white.withValues(alpha: 0.05),
                  ]
                : [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.02),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.10),
            width: 0.8,
          ),
        ),
        child: Column(
          children: options.map((opt) {
            final (value, label) = opt;
            final isSelected = selected == value;
            return InkWell(
              onTap: () => onSelect(value),
              splashFactory: NoSplash.splashFactory,
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? colors.textPrimary
                            : colors.textSecondary,
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    ?(isSelected
                        ? Icon(Icons.check_rounded,
                            size: 16, color: colors.textPrimary)
                        : null),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
          ),
        ),
      ),
    );
  }
}
