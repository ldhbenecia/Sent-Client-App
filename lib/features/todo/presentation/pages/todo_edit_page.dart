import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../widgets/category_picker_sheet.dart';
import '../../domain/models/todo_item.dart';
import '../../domain/models/todo_category.dart';

// ══════════════════════════════════════════════════════════════════
// TodoEditPage — 투두 생성/수정
// ══════════════════════════════════════════════════════════════════
class TodoEditPage extends ConsumerStatefulWidget {
  const TodoEditPage({super.key, this.todo, this.initialDate});

  final TodoItem? todo;          // null = 생성 모드
  final DateTime? initialDate;  // 생성 모드에서 기본 날짜

  @override
  ConsumerState<TodoEditPage> createState() => _TodoEditPageState();
}

class _TodoEditPageState extends ConsumerState<TodoEditPage> {
  late final TextEditingController _titleCtrl;
  late DateTime _date;
  String? _categoryId;
  TimeOfDay? _time;
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

  // ── 날짜 포맷 ─────────────────────────────────────────────────
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.destructiveRed,
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
    // result == '' 이면 "없음" 선택
    if (result != null) {
      setState(() => _categoryId = result.isEmpty ? null : result);
    }
  }

  // ── 시간 선택 ─────────────────────────────────────────────────
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.foreground,
            onPrimary: AppColors.background,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(todoCategoriesProvider).valueOrNull ?? [];
    final selectedCat = _categoryId != null
        ? categories.firstWhere(
            (c) => c.id == _categoryId,
            orElse: () => TodoCategory(
              id: _categoryId!,
              name: '알 수 없음',
              color: AppColors.textMuted,
              icon: Icons.circle_outlined,
            ),
          )
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textPrimary, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _formatDate(_date),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _titleCtrl.text.trim().isNotEmpty ? _save : null,
            child: Text(
              '등록',
              style: TextStyle(
                color: _titleCtrl.text.trim().isNotEmpty
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
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
          const Divider(height: 0.5, color: AppColors.border),
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: '내용을 입력하세요',
                      hintStyle: TextStyle(
                        color: AppColors.textPlaceholder,
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

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child:
                      Divider(height: 0.5, thickness: 0.5, color: AppColors.border),
                ),

                // 카테고리
                _FormRow(
                  label: '카테고리',
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
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          '없음',
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 14,
                          ),
                        ),
                ),

                // 시간 선택
                _FormRow(
                  label: '시간 선택',
                  onTap: _pickTime,
                  trailing: _time != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(_time!),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => setState(() => _time = null),
                              child: const Icon(Icons.close_rounded,
                                  size: 14, color: AppColors.textDisabled),
                            ),
                          ],
                        )
                      : const Text(
                          '없음',
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 14,
                          ),
                        ),
                ),

                // 알림 (stub)
                const _FormRow(
                  label: '알림',
                  trailing: Text(
                    '없음',
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 삭제 버튼 (수정 모드만)
          if (_isEdit) ...[
            const Divider(height: 0.5, color: AppColors.border),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      ref
                          .read(todoItemsProvider.notifier)
                          .remove(widget.todo!.id);
                      context.pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.destructiveRed.withOpacity(0.12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '삭제',
                      style: TextStyle(
                        color: AppColors.destructiveRed,
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
  });

  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing!,
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textDisabled),
            ],
          ],
        ),
      ),
    );
  }
}

