import 'money.dart';

/// The guide documents the /payments request filter shape but not the
/// response row shape, and the test account currently has zero payment
/// records to sample. This parses defensively across the field-name
/// variants used elsewhere in the API (invoice/statement rows) so it
/// degrades gracefully rather than crashing once real payment rows exist —
/// revisit and tighten once a real sample is available.
class PaymentRow {
  final int id;
  final DateTime? paymentDate;
  final double amount;
  final int currency;
  final String? reference;
  final String? method;
  final Map<String, dynamic> raw;

  PaymentRow({
    required this.id,
    this.paymentDate,
    required this.amount,
    required this.currency,
    this.reference,
    this.method,
    required this.raw,
  });

  factory PaymentRow.fromJson(Map<String, dynamic> json) {
    return PaymentRow(
      id: json['id'] ?? 0,
      paymentDate: DateTime.tryParse((json['payment_date'] ?? json['date'] ?? '').toString()),
      amount: asDouble(json['amount'] ?? json['payment_amount']),
      currency: json['currency'] ?? json['payment_currency'] ?? 0,
      reference: json['reference']?.toString(),
      method: json['method']?.toString() ?? json['payment_method']?.toString(),
      raw: json,
    );
  }
}

class PaymentsSummary {
  final int count;
  final double totalAmount;

  PaymentsSummary({required this.count, required this.totalAmount});

  factory PaymentsSummary.fromJson(Map<String, dynamic> json) {
    return PaymentsSummary(count: json['count'] ?? 0, totalAmount: asDouble(json['total_amount']));
  }
}

class PaymentsResult {
  final PaymentsSummary summary;
  final List<PaymentRow> rows;
  final String? currencyLabel;

  PaymentsResult({required this.summary, required this.rows, this.currencyLabel});

  factory PaymentsResult.fromJson(Map<String, dynamic> json) {
    return PaymentsResult(
      summary: PaymentsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      rows: (json['rows'] as List<dynamic>? ?? []).map((r) => PaymentRow.fromJson(r as Map<String, dynamic>)).toList(),
      currencyLabel: (json['filters'] as Map<String, dynamic>?)?['currency_label'] as String?,
    );
  }
}
