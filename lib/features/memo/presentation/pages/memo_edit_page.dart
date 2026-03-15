import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../providers/memo_provider.dart';
import '../widgets/memo_category_picker_sheet.dart';
import '../../domain/models/memo_item.dart';
import '../../domain/models/memo_category.dart';

// ══════════════════════════════════════════════════════════════════
// MemoEditPage — 메모 생성/수정
// ══════════════════════════════════════════════════════════════════
class MemoEditPage extends ConsumerStatefulWidget {
  const MemoEditPage({super.key, this.memo});

  final MemoItem? memo;

  @override
  ConsumerState<MemoEditPage> createState() => _MemoEditPageState();
}

class _MemoEditPageState extends ConsumerState<MemoEditPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  late final TextEditingController _tagsCtrl;
  MemoCategory? _selectedCategory;
  MemoCategory? _originalCategory;

  bool _isSaving = false;

  bool get _isEdit => widget.memo != null;

  @override
  void initState() {
    super.initState();
    final memo = widget.memo;
    _titleCtrl = TextEditingController(text: memo?.title ?? '');
    _contentCtrl = TextEditingController(text: memo?.content ?? '');
    _tagsCtrl = TextEditingController(
      text: memo?.tags.isNotEmpty == true ? memo!.tags.join(', ') : '',
    );
    _selectedCategory = memo?.category;
    _originalCategory = memo?.category;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final content = _contentCtrl.text.trim();
      final tags = _parseTags(_tagsCtrl.text);
      final notifier = ref.read(memoItemsProvider.notifier);

      if (_isEdit) {
        final categoryIdUpdated =
            _selectedCategory?.id != _originalCategory?.id;
        await notifier.edit(
          widget.memo!.copyWith(
            title: title,
            content: content.isNotEmpty ? content : null,
            category: _selectedCategory,
            tags: tags,
            clearCategory: _selectedCategory == null,
            clearContent: content.isEmpty,
          ),
          categoryIdUpdated: categoryIdUpdated,
        );
      } else {
        await notifier.add(
          title: title,
          content: content.isNotEmpty ? content : null,
          category: _selectedCategory,
          tags: tags,
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      showTopToast(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickCategory() async {
    final categories = ref.read(memoCategoriesProvider).valueOrNull ?? [];
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MemoCategoryPickerSheet(
        categories: categories,
        selectedId: _selectedCategory?.id,
        onManage: () => context.push('/memo/categories'),
      ),
    );
    if (!mounted) return;
    if (result != null) {
      if (result.isEmpty) {
        setState(() => _selectedCategory = null);
      } else {
        final cat = categories.firstWhere(
          (c) => c.id == result,
          orElse: () => categories.first,
        );
        setState(() => _selectedCategory = cat);
      }
    }
  }

  bool get _canSave => _titleCtrl.text.trim().isNotEmpty && !_isSaving;

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
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _canSave ? _save : null,
              child: Text(
                _isEdit ? l10n.save : l10n.register,
                style: TextStyle(
                  color: _canSave ? colors.textPrimary : colors.textDisabled,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                // ── 제목 + 내용 카드 ──────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: TextField(
                          controller: _titleCtrl,
                          autofocus: !_isEdit,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.memoTitleHint,
                            hintStyle: TextStyle(
                              color: colors.textPlaceholder,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                        child: TextField(
                          controller: _contentCtrl,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                            height: 1.55,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.memoContentHint,
                            hintStyle: TextStyle(
                              color: colors.textPlaceholder,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: null,
                          minLines: 4,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── 메타 카드 (카테고리 + 태그) ──────────────────
                Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      // 카테고리 행
                      InkWell(
                        onTap: _pickCategory,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Text(
                                l10n.todoCategory,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedCategory != null) ...[
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _selectedCategory!.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _selectedCategory!.name,
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              ] else
                                Text(
                                  l10n.none,
                                  style: TextStyle(
                                    color: colors.textDisabled,
                                    fontSize: 14,
                                  ),
                                ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded,
                                  size: 18, color: colors.textDisabled),
                            ],
                          ),
                        ),
                      ),

                      Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: colors.border,
                          indent: 16),

                      // 태그 행
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              l10n.memoTags,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _tagsCtrl,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.memoTagsHint,
                                  hintStyle: TextStyle(
                                    color: colors.textPlaceholder,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 삭제 버튼 (수정 모드만) ──────────────────────────
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
                                  style:
                                      TextStyle(color: colors.textMuted)),
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
                          .read(memoItemsProvider.notifier)
                          .remove(widget.memo!.id);
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
