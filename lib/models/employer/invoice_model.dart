import 'money.dart';

class InvoiceRow {
  final int id;
  final int returnsSubmissionId;
  final DateTime invoiceDate;
  final double invoiceTotal;
  final double amountPaid;
  final double balance;
  final int payStatus;
  final int invoiceMonth;
  final int invoiceYear;
  final int currency;
  final String remarks;

  InvoiceRow({
    required this.id,
    required this.returnsSubmissionId,
    required this.invoiceDate,
    required this.invoiceTotal,
    required this.amountPaid,
    required this.balance,
    required this.payStatus,
    required this.invoiceMonth,
    required this.invoiceYear,
    required this.currency,
    required this.remarks,
  });

  bool get isPaid => payStatus == 1;

  factory InvoiceRow.fromJson(Map<String, dynamic> json) {
    return InvoiceRow(
      id: json['id'] ?? 0,
      returnsSubmissionId: json['returns_submission_id'] ?? 0,
      invoiceDate: DateTime.tryParse(json['invoice_date'] ?? '') ?? DateTime.now(),
      invoiceTotal: asDouble(json['invoice_total']),
      amountPaid: asDouble(json['amount_paid']),
      balance: asDouble(json['balance']),
      payStatus: json['pay_status'] ?? 0,
      invoiceMonth: json['invoice_month'] ?? 0,
      invoiceYear: json['invoice_year'] ?? 0,
      currency: json['currency'] ?? 0,
      remarks: json['remarks'] ?? '',
    );
  }
}

class InvoicesSummary {
  final int count;
  final double invoiceTotal;
  final double amountPaid;
  final double balanceTotal;

  InvoicesSummary({required this.count, required this.invoiceTotal, required this.amountPaid, required this.balanceTotal});

  factory InvoicesSummary.fromJson(Map<String, dynamic> json) {
    return InvoicesSummary(
      count: json['count'] ?? 0,
      invoiceTotal: asDouble(json['invoice_total']),
      amountPaid: asDouble(json['amount_paid']),
      balanceTotal: asDouble(json['balance_total']),
    );
  }
}

class InvoicesResult {
  final InvoicesSummary summary;
  final List<InvoiceRow> rows;
  final String? currencyLabel;

  InvoicesResult({required this.summary, required this.rows, this.currencyLabel});

  factory InvoicesResult.fromJson(Map<String, dynamic> json) {
    return InvoicesResult(
      summary: InvoicesSummary.fromJson(json['summary'] as Map<String, dynamic>),
      rows: (json['rows'] as List<dynamic>? ?? []).map((r) => InvoiceRow.fromJson(r as Map<String, dynamic>)).toList(),
      currencyLabel: (json['filters'] as Map<String, dynamic>?)?['currency_label'] as String?,
    );
  }
}
