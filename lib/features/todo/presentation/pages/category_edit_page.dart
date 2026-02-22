import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../../domain/models/todo_category.dart';

// ══════════════════════════════════════════════════════════════════
// CategoryEditPage — 카테고리 생성/수정
// ══════════════════════════════════════════════════════════════════
class CategoryEditPage extends ConsumerStatefulWidget {
  const CategoryEditPage({super.key, required this.category});

  final TodoCategory? category; // null = 생성 모드

  @override
  ConsumerState<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends ConsumerState<CategoryEditPage> {
  late final TextEditingController _nameCtrl;
  late IconData _selectedIcon;
  late Color _selectedColor;

  bool get _isEdit => widget.category != null;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    _nameCtrl = TextEditingController(text: cat?.name ?? '');
    _selectedIcon = cat?.icon ?? kCategoryIcons.first;
    _selectedColor = cat?.color ?? AppColors.categoryRed;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(todoCategoriesProvider.notifier);
      if (_isEdit) {
        await notifier.edit(widget.category!.copyWith(
          name: name,
          color: _selectedColor,
          icon: _selectedIcon,
        ));
      } else {
        await notifier.add(
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded,
              color: AppColors.textPrimary, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '카테고리 편집',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Divider(height: 0.5, color: AppColors.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 이름 입력 + 저장 행
                _NameRow(
                  controller: _nameCtrl,
                  selectedIcon: _selectedIcon,
                  selectedColor: _selectedColor,
                  onSave: _nameCtrl.text.trim().isNotEmpty ? _save : null,
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 24),

                // 아이콘 선택
                _SectionHeader(label: '아이콘'),
                const SizedBox(height: 12),
                _IconGrid(
                  selected: _selectedIcon,
                  onSelect: (icon) => setState(() => _selectedIcon = icon),
                ),

                const SizedBox(height: 24),

                // 색상 선택
                _SectionHeader(
                  label: '색상',
                  sub: _colorHex(_selectedColor),
                ),
                const SizedBox(height: 12),
                _ColorPicker(
                  selected: _selectedColor,
                  onSelect: (color) => setState(() => _selectedColor = color),
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
                    onPressed: () async {
                      try {
                        // 이 카테고리의 투두들 카테고리 해제
                        final todos =
                            ref.read(todoItemsProvider).valueOrNull ?? [];
                        final todoNotifier =
                            ref.read(todoItemsProvider.notifier);
                        for (final todo in todos) {
                          if (todo.categoryId == widget.category!.id) {
                            await todoNotifier
                                .edit(todo.copyWith(clearCategory: true));
                          }
                        }
                        await ref
                            .read(todoCategoriesProvider.notifier)
                            .remove(widget.category!.id);
                        if (mounted) context.pop();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: AppColors.destructiveRed,
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          AppColors.destructiveRed.withOpacity(0.12),
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

  String _colorHex(Color c) => colorToHex(c);
}

// ══════════════════════════════════════════════════════════════════
// 이름 입력 행
// ══════════════════════════════════════════════════════════════════
class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.controller,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onSave,
    required this.onChanged,
  });

  final TextEditingController controller;
  final IconData selectedIcon;
  final Color selectedColor;
  final VoidCallback? onSave;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // 미리보기 아이콘
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selectedColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                Icon(selectedIcon, size: 18, color: selectedColor),
          ),
          const SizedBox(width: 10),
          // 이름 입력
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: '이름을 입력하세요',
                hintStyle: TextStyle(
                  color: AppColors.textPlaceholder,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          // 저장 버튼
          GestureDetector(
            onTap: onSave,
            child: Text(
              '저장',
              style: TextStyle(
                color: onSave != null
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 섹션 헤더
// ══════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.sub});

  final String label;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(width: 8),
          Text(
            sub!,
            style: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 아이콘 그리드
// ══════════════════════════════════════════════════════════════════
class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.selected, required this.onSelect});

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
class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelect});

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
