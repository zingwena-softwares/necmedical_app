import 'money.dart';

/// As with [PaymentRow], the guide documents the upload request fields but
/// not the list response row shape, and the test account has zero payment
/// proofs to sample yet. Parsed defensively; revisit once real data exists.
class PaymentProof {
  final int id;
  final DateTime? paymentDate;
  final double amount;
  final int currency;
  final String status;
  final String? fileUrl;
  final Map<String, dynamic> raw;

  PaymentProof({
    required this.id,
    this.paymentDate,
    required this.amount,
    required this.currency,
    required this.status,
    this.fileUrl,
    required this.raw,
  });

  factory PaymentProof.fromJson(Map<String, dynamic> json) {
    return PaymentProof(
      id: json['id'] ?? 0,
      paymentDate: DateTime.tryParse((json['payment_date'] ?? '').toString()),
      amount: asDouble(json['payment_amount'] ?? json['amount']),
      currency: json['payment_currency'] ?? json['currency'] ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      fileUrl: json['file_url']?.toString() ?? json['payment_proof_file']?.toString(),
      raw: json,
    );
  }
}

class PaymentProofsResult {
  final int count;
  final List<PaymentProof> rows;

  PaymentProofsResult({required this.count, required this.rows});

  factory PaymentProofsResult.fromJson(Map<String, dynamic> json) {
    return PaymentProofsResult(
      count: (json['summary'] as Map<String, dynamic>?)?['count'] ?? 0,
      rows: (json['rows'] as List<dynamic>? ?? []).map((r) => PaymentProof.fromJson(r as Map<String, dynamic>)).toList(),
    );
  }
}
