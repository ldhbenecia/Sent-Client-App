enum LedgerType {
  income,
  expense;

  String toJson() => name.toUpperCase(); // income → INCOME

  static LedgerType fromJson(String value) => switch (value.toUpperCase()) {
        'INCOME' => LedgerType.income,
        _ => LedgerType.expense,
      };

  String get label => switch (this) {
        LedgerType.income => '수입',
        LedgerType.expense => '지출',
      };
}

enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  transfer;

  String toJson() => switch (this) {
        PaymentMethod.cash => 'CASH',
        PaymentMethod.creditCard => 'CREDIT_CARD',
        PaymentMethod.debitCard => 'DEBIT_CARD',
        PaymentMethod.transfer => 'TRANSFER',
      };

  static PaymentMethod fromJson(String value) =>
      switch (value.toUpperCase()) {
        'CASH' => PaymentMethod.cash,
        'CREDIT_CARD' => PaymentMethod.creditCard,
        'DEBIT_CARD' => PaymentMethod.debitCard,
        'TRANSFER' => PaymentMethod.transfer,
        _ => PaymentMethod.cash,
      };

  String get label => switch (this) {
        PaymentMethod.cash => '현금',
        PaymentMethod.creditCard => '신용카드',
        PaymentMethod.debitCard => '체크카드',
        PaymentMethod.transfer => '계좌이체',
      };
}
