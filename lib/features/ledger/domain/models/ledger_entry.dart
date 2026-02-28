import 'ledger_enums.dart';

class LedgerEntry {
  final String id;
  final LedgerType type;
  final int amount;
  final PaymentMethod paymentMethod;
  final String? categoryId;
  final String? memo;
  final DateTime transactionDate;

  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.paymentMethod,
    this.categoryId,
    this.memo,
    required this.transactionDate,
  });

  LedgerEntry copyWith({
    LedgerType? type,
    int? amount,
    PaymentMethod? paymentMethod,
    String? categoryId,
    String? memo,
    DateTime? transactionDate,
  }) {
    return LedgerEntry(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      categoryId: categoryId ?? this.categoryId,
      memo: memo ?? this.memo,
      transactionDate: transactionDate ?? this.transactionDate,
    );
  }
}
