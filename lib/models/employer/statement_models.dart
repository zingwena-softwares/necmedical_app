import 'money.dart';

class StatementSummary {
  final double openingDebit;
  final double openingCredit;
  final double openingBalance;
  final double closingBalance;

  StatementSummary({
    required this.openingDebit,
    required this.openingCredit,
    required this.openingBalance,
    required this.closingBalance,
  });

  factory StatementSummary.fromJson(Map<String, dynamic> json) {
    return StatementSummary(
      openingDebit: asDouble(json['opening_debit']),
      openingCredit: asDouble(json['opening_credit']),
      openingBalance: asDouble(json['opening_balance']),
      closingBalance: asDouble(json['closing_balance']),
    );
  }
}

class StatementRow {
  final DateTime date;
  final String entryType;
  final String? reference;
  final String description;
  final double debit;
  final double credit;
  final double runningBalance;

  StatementRow({
    required this.date,
    required this.entryType,
    this.reference,
    required this.description,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });

  bool get isBbf => entryType.toUpperCase() == 'BBF';

  factory StatementRow.fromJson(Map<String, dynamic> json) {
    return StatementRow(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      entryType: json['entry_type'] ?? '',
      reference: json['reference']?.toString(),
      description: json['description'] ?? '',
      debit: asDouble(json['debit']),
      credit: asDouble(json['credit']),
      runningBalance: asDouble(json['running_balance']),
    );
  }
}

class StatementsResult {
  final StatementSummary summary;
  final List<StatementRow> rows;
  final String? currencyLabel;

  StatementsResult({required this.summary, required this.rows, this.currencyLabel});

  factory StatementsResult.fromJson(Map<String, dynamic> json) {
    return StatementsResult(
      summary: StatementSummary.fromJson(json['summary'] as Map<String, dynamic>),
      rows: (json['rows'] as List<dynamic>? ?? [])
          .map((r) => StatementRow.fromJson(r as Map<String, dynamic>))
          .toList(),
      currencyLabel: (json['filters'] as Map<String, dynamic>?)?['currency_label'] as String?,
    );
  }
}
