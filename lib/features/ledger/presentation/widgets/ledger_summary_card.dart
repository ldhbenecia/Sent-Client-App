import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../domain/models/ledger_summary.dart';

class LedgerSummaryCard extends StatelessWidget {
  const LedgerSummaryCard({super.key, required this.summary});

  final LedgerSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _SummaryItem(
            label: l10n.income,
            amount: summary.totalIncome,
            color: const Color(0xFF32D74B),
          ),
          const SizedBox(width: 1),
          _Divider(),
          const SizedBox(width: 1),
          _SummaryItem(
            label: l10n.expense,
            amount: summary.totalExpense,
            color: const Color(0xFFFF6467),
          ),
          _Divider(),
          _SummaryItem(
            label: l10n.netAmount,
            amount: summary.netAmount,
            color: summary.netAmount >= 0
                ? const Color(0xFF32D74B)
                : const Color(0xFFFF6467),
            isNet: true,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 0.5,
      height: 32,
      color: colors.border,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    this.isNet = false,
  });

  final String label;
  final int amount;
  final Color color;
  final bool isNet;

  static String _format(int n, String symbol) {
    final abs = n.abs();
    final formatted = abs
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '${n < 0 ? '-' : ''}$formatted$symbol';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final symbol = AppLocalizations.of(context)!.currencySymbol;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _format(amount, symbol),
            style: TextStyle(
              color: color,
              fontSize: isNet ? 15 : 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
