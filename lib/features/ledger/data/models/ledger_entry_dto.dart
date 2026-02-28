import '../../domain/models/ledger_entry.dart';
import '../../domain/models/ledger_enums.dart';

class LedgerEntryDto {
  final int id;
  final String type;
  final int amount;
  final String paymentMethod;
  final int? categoryId;
  final String? memo;
  final String transactionDate; // "yyyy-MM-dd"

  const LedgerEntryDto({
    required this.id,
    required this.type,
    required this.amount,
    required this.paymentMethod,
    this.categoryId,
    this.memo,
    required this.transactionDate,
  });

  factory LedgerEntryDto.fromJson(Map<String, dynamic> json) => LedgerEntryDto(
        id: (json['id'] as num).toInt(),
        type: json['type'] as String,
        amount: (json['amount'] as num).toInt(),
        paymentMethod: json['paymentMethod'] as String,
        categoryId: json['categoryId'] != null
            ? (json['categoryId'] as num).toInt()
            : null,
        memo: json['memo'] as String?,
        transactionDate: json['transactionDate'] as String,
      );

  LedgerEntry toDomain() => LedgerEntry(
        id: id.toString(),
        type: LedgerType.fromJson(type),
        amount: amount,
        paymentMethod: PaymentMethod.fromJson(paymentMethod),
        categoryId: categoryId?.toString(),
        memo: memo,
        transactionDate: DateTime.parse(transactionDate),
      );
}
