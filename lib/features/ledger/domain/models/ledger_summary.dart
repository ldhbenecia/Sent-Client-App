class CategorySummary {
  final String? categoryId;
  final String? categoryName;
  final int totalAmount;

  const CategorySummary({
    this.categoryId,
    this.categoryName,
    required this.totalAmount,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) =>
      CategorySummary(
        categoryId: json['categoryId']?.toString(),
        categoryName: json['categoryName'] as String?,
        totalAmount: (json['totalAmount'] as num).toInt(),
      );
}

class PaymentMethodSummary {
  final String paymentMethod;
  final int totalAmount;

  const PaymentMethodSummary({
    required this.paymentMethod,
    required this.totalAmount,
  });

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) =>
      PaymentMethodSummary(
        paymentMethod: json['paymentMethod'] as String,
        totalAmount: (json['totalAmount'] as num).toInt(),
      );
}

class LedgerSummary {
  final int totalIncome;
  final int totalExpense;
  final int netAmount;
  final List<CategorySummary> categoryBreakdown;
  final List<PaymentMethodSummary> paymentMethodBreakdown;

  const LedgerSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.categoryBreakdown,
    required this.paymentMethodBreakdown,
  });

  factory LedgerSummary.fromJson(Map<String, dynamic> json) => LedgerSummary(
        totalIncome: (json['totalIncome'] as num).toInt(),
        totalExpense: (json['totalExpense'] as num).toInt(),
        netAmount: (json['netAmount'] as num).toInt(),
        categoryBreakdown: (json['categoryBreakdown'] as List? ?? [])
            .map((e) => CategorySummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        paymentMethodBreakdown:
            (json['paymentMethodBreakdown'] as List? ?? [])
                .map((e) =>
                    PaymentMethodSummary.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  factory LedgerSummary.empty() => const LedgerSummary(
        totalIncome: 0,
        totalExpense: 0,
        netAmount: 0,
        categoryBreakdown: [],
        paymentMethodBreakdown: [],
      );
}
