import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/models/ledger_summary.dart';

class LedgerSummaryCard extends StatelessWidget {
  const LedgerSummaryCard({super.key, required this.summary});

  final LedgerSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _SummaryItem(
            label: '수입',
            amount: summary.totalIncome,
            color: const Color(0xFF32D74B),
          ),
          const SizedBox(width: 1),
          _Divider(),
          const SizedBox(width: 1),
          _SummaryItem(
            label: '지출',
            amount: summary.totalExpense,
            color: const Color(0xFFFF6467),
          ),
          _Divider(),
          _SummaryItem(
            label: '순액',
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
    return Container(
      width: 0.5,
      height: 32,
      color: AppColors.border,
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

  static String _format(int n) {
    final abs = n.abs();
    final formatted = abs
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '${n < 0 ? '-' : ''}$formatted원';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _format(amount),
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
