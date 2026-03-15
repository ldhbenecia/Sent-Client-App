import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../../shared/widgets/top_toast.dart';
import '../providers/ledger_provider.dart';
import '../../domain/models/ledger_category.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/models/ledger_enums.dart';

// ══════════════════════════════════════════════════════════════════
// LedgerEntryEditPage — 항목 생성/수정
// ══════════════════════════════════════════════════════════════════
class LedgerEntryEditPage extends ConsumerStatefulWidget {
  const LedgerEntryEditPage({super.key, this.entry, this.initialDate});

  final LedgerEntry? entry; // null = 생성 모드
  final DateTime? initialDate; // 캘린더 선택일 기본값

  @override
  ConsumerState<LedgerEntryEditPage> createState() =>
      _LedgerEntryEditPageState();
}

class _LedgerEntryEditPageState extends ConsumerState<LedgerEntryEditPage> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _memoCtrl;
  late LedgerType _type;
  late PaymentMethod _paymentMethod;
  late DateTime _transactionDate;
  String? _categoryId;
  bool _isSaving = false;

  bool get _isEdit => widget.entry != null;

  static String _formatWithCommas(int n) => n
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _type = e?.type ?? LedgerType.expense;
    _amountCtrl = TextEditingController(
      text: e != null ? _formatWithCommas(e.amount) : '',
    );
    _memoCtrl = TextEditingController(text: e?.memo ?? '');
    _paymentMethod = e?.paymentMethod ?? PaymentMethod.creditCard;
    final providerDate = ref.read(ledgerNewEntryInitialDateProvider);
    _transactionDate =
        e?.transactionDate ?? widget.initialDate ?? providerDate ?? DateTime.now();
    // 읽은 후 리셋
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ledgerNewEntryInitialDateProvider.notifier).state = null;
    });
    _categoryId = e?.categoryId;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월',
    ];
    return '${d.year}년 ${months[d.month - 1]} ${d.day}일';
  }

  int get _parsedAmount =>
      int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;

  bool get _canSave => _parsedAmount > 0 && !_isSaving;

  Future<void> _save() async {
    if (!_canSave) return;
    final amount = _parsedAmount;
    final memo = _memoCtrl.text.trim();

    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(ledgerEntriesProvider.notifier);
      if (_isEdit) {
        await notifier.edit(widget.entry!.copyWith(
          type: _type,
          amount: amount,
          paymentMethod: _paymentMethod,
          categoryId: _categoryId,
          memo: memo.isEmpty ? null : memo,
          transactionDate: _transactionDate,
        ));
      } else {
        await notifier.add(
          type: _type,
          amount: amount,
          paymentMethod: _paymentMethod,
          categoryId: _categoryId,
          memo: memo.isEmpty ? null : memo,
          transactionDate: _transactionDate,
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

  Future<void> _pickDate() async {
    DateTime temp = _transactionDate;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DatePickerSheet(
        initialDate: _transactionDate,
        onChanged: (d) => temp = d,
        onConfirm: () {
          setState(() => _transactionDate = temp);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _pickCategory() async {
    final categories = ref.read(ledgerCategoriesProvider).valueOrNull ?? [];
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CategoryPickerSheet(
        categories: categories,
        selectedId: _categoryId,
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
    final categories = ref.watch(ledgerCategoriesProvider).valueOrNull ?? [];
    final selectedCat = _categoryId != null
        ? categories.cast<LedgerCategory?>().firstWhere(
              (c) => c?.id == _categoryId,
              orElse: () => null,
            )
        : null;

    final typeColor = _type == LedgerType.expense
        ? const Color(0xFFFF6467)
        : const Color(0xFF32D74B);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded,
              color: colors.textPrimary, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEdit ? l10n.editEntry : l10n.addEntry,
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
            onPressed: _canSave ? _save : null,
            child: _isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: colors.textMuted,
                    ),
                  )
                : Text(
                    _isEdit ? l10n.edit : l10n.register,
                    style: TextStyle(
                      color: _canSave
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
                // ── 수입/지출 토글 ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      _TypeChip(
                        label: l10n.expense,
                        selected: _type == LedgerType.expense,
                        color: const Color(0xFFFF6467),
                        onTap: () => setState(() => _type = LedgerType.expense),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(
                        label: l10n.income,
                        selected: _type == LedgerType.income,
                        color: const Color(0xFF32D74B),
                        onTap: () => setState(() => _type = LedgerType.income),
                      ),
                    ],
                  ),
                ),

                // ── 금액 입력 ──────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          autofocus: !_isEdit,
                          keyboardType: TextInputType.number,
                          inputFormatters: [_ThousandsFormatter()],
                          style: TextStyle(
                            color: _parsedAmount > 0
                                ? typeColor
                                : colors.textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: colors.textPlaceholder,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.currencySymbol,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                      height: 0.5, thickness: 0.5, color: colors.border),
                ),

                // ── 거래일 ─────────────────────────────────────────
                _FormRow(
                  label: l10n.transactionDate,
                  onTap: _pickDate,
                  trailing: Text(
                    _formatDate(_transactionDate),
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),

                // ── 결제수단 ───────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.paymentMethod,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: PaymentMethod.values.map((m) {
                          final isSelected = m == _paymentMethod;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _paymentMethod = m),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: EdgeInsets.only(
                                    right: m != PaymentMethod.values.last
                                        ? 6
                                        : 0),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary700
                                      : colors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary500
                                        : colors.border,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  m.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? colors.textPrimary
                                        : colors.textDisabled,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                      height: 0.5, thickness: 0.5, color: colors.border),
                ),

                // ── 카테고리 ───────────────────────────────────────
                _FormRow(
                  label: l10n.ledgerCategory,
                  onTap: _pickCategory,
                  trailing: selectedCat != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: selectedCat.color
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(selectedCat.icon,
                                  size: 11, color: selectedCat.color),
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

                // ── 메모 ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: TextField(
                    controller: _memoCtrl,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.memoOptionalHint,
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
                  ),
                ),
              ],
            ),
          ),

          // ── 삭제 버튼 (수정 모드) ──────────────────────────────────
          if (_isEdit) ...[
            Divider(height: 0.5, color: colors.border),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      ref
                          .read(ledgerEntriesProvider.notifier)
                          .remove(widget.entry!.id);
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

// ── 천 단위 콤마 포매터 ──────────────────────────────────────────
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── 수입/지출 토글 칩 ─────────────────────────────────────────────
class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : colors.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : colors.border,
            width: selected ? 1.0 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : colors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── 폼 행 위젯 ────────────────────────────────────────────────────
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
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: colors.textDisabled),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 카테고리 선택 시트 ────────────────────────────────────────────
class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedId,
  });

  final List<LedgerCategory> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    l10n.categorySelect,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/ledger/categories');
                    },
                    child: Text(
                      l10n.manage,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 없음 옵션
            ListTile(
              onTap: () => Navigator.of(context).pop(''),
              leading: Icon(Icons.block_rounded,
                  color: colors.textMuted, size: 20),
              title: Text(l10n.none,
                  style: TextStyle(color: colors.textMuted, fontSize: 14)),
              trailing: selectedId == null
                  ? Icon(Icons.check_rounded,
                      color: colors.textPrimary, size: 18)
                  : null,
            ),
            Divider(height: 0.5, color: colors.border, indent: 16),
            ...categories.map((c) => ListTile(
                  onTap: () => Navigator.of(context).pop(c.id),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(c.icon, size: 14, color: c.color),
                  ),
                  title: Text(c.name,
                      style: TextStyle(
                          color: colors.textPrimary, fontSize: 14)),
                  trailing: selectedId == c.id
                      ? Icon(Icons.check_rounded,
                          color: colors.textPrimary, size: 18)
                      : null,
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── 날짜 선택 바텀시트 ────────────────────────────────────────────
class _DatePickerSheet extends StatelessWidget {
  const _DatePickerSheet({
    required this.initialDate,
    required this.onChanged,
    required this.onConfirm,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Text(
                    l10n.selectDate,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onConfirm,
                    child: Text(
                      l10n.confirm,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initialDate,
                minimumDate: DateTime(2020),
                maximumDate: DateTime(2030, 12, 31),
                onDateTimeChanged: onChanged,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
