import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/models/ledger_category.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/models/ledger_enums.dart';

class LedgerEntryTile extends StatelessWidget {
  const LedgerEntryTile({
    super.key,
    required this.entry,
    this.category,
    this.onTap,
    this.onDelete,
  });

  final LedgerEntry entry;
  final LedgerCategory? category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  static String _formatAmount(int amount) => amount
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == LedgerType.income;
    final amountColor =
        isIncome ? const Color(0xFF32D74B) : const Color(0xFFFF6467);
    final amountSign = isIncome ? '+' : '-';

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.04),
      highlightColor: Colors.white.withValues(alpha: 0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: category != null
                    ? category!.color.withValues(alpha: 0.15)
                    : AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category?.icon ?? Icons.receipt_rounded,
                size: 18,
                color: category?.color ?? AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 12),

            // 메모 + 결제수단
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.memo?.isNotEmpty == true
                        ? entry.memo!
                        : (category?.name ?? entry.type.label),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.paymentMethod.label,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // 금액
            Text(
              '$amountSign${_formatAmount(entry.amount)}원',
              style: TextStyle(
                color: amountColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (onDelete != null) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
