import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../todo/presentation/widgets/category_pickers.dart';
import '../providers/ledger_provider.dart';
import '../../domain/models/ledger_category.dart';

// ══════════════════════════════════════════════════════════════════
// LedgerCategoryEditPage — 가계부 카테고리 생성/수정
// ══════════════════════════════════════════════════════════════════
class LedgerCategoryEditPage extends ConsumerStatefulWidget {
  const LedgerCategoryEditPage({super.key, required this.category});

  final LedgerCategory? category; // null = 생성 모드

  @override
  ConsumerState<LedgerCategoryEditPage> createState() =>
      _LedgerCategoryEditPageState();
}

class _LedgerCategoryEditPageState
    extends ConsumerState<LedgerCategoryEditPage> {
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
    _selectedColor = cat?.color ?? AppColors.categoryBlue;
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
      final notifier = ref.read(ledgerCategoriesProvider.notifier);
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
          backgroundColor: context.colors.destructiveRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded,
              color: colors.textPrimary, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.categoryEdit,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Divider(height: 0.5, color: colors.border),
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
                _SectionLabel(label: l10n.categoryIcon),
                const SizedBox(height: 12),
                CategoryIconGrid(
                  selected: _selectedIcon,
                  onSelect: (icon) => setState(() => _selectedIcon = icon),
                ),

                const SizedBox(height: 24),

                // 색상 선택
                _SectionLabel(
                  label: l10n.categoryColor,
                  sub: colorToHex(_selectedColor),
                ),
                const SizedBox(height: 12),
                CategoryColorPicker(
                  selected: _selectedColor,
                  onSelect: (color) =>
                      setState(() => _selectedColor = color),
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
                      final messenger = ScaffoldMessenger.of(context);
                      final deleteRed = context.colors.destructiveRed;
                      final navigator = Navigator.of(context);
                      try {
                        await ref
                            .read(ledgerCategoriesProvider.notifier)
                            .remove(widget.category!.id);
                        if (mounted) navigator.pop();
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                e.toString().replaceAll('Exception: ', '')),
                            backgroundColor: deleteRed,
                          ),
                        );
                      }
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

// ── 이름 입력 행 ───────────────────────────────────────────────────
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selectedColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(selectedIcon, size: 18, color: selectedColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: l10n.categoryNameHint,
                hintStyle: TextStyle(
                  color: colors.textPlaceholder,
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
          GestureDetector(
            onTap: onSave,
            child: Text(
              l10n.save,
              style: TextStyle(
                color: onSave != null
                    ? colors.textPrimary
                    : colors.textDisabled,
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

// ── 섹션 라벨 ──────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.sub});

  final String label;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (sub != null) ...[
          const SizedBox(width: 8),
          Text(
            sub!,
            style: TextStyle(
              color: colors.textDisabled,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
