/// Field names here are best-effort — the API doc doesn't spell out the
/// exact shape of a levy/payment record, and the test account has none to
/// verify against yet. Parsing is defensive (tries a few likely key names)
/// so the UI degrades gracefully rather than crashing if a name is off.
double _asDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v != null && v.toString().isNotEmpty) return v.toString();
  }
  return null;
}

class Levy {
  final int id;
  final String? description;
  final String? period;
  final double amountBilled;
  final double amountPaid;
  final double amountOwing;
  final String? status;

  const Levy({
    required this.id,
    this.description,
    this.period,
    this.amountBilled = 0,
    this.amountPaid = 0,
    this.amountOwing = 0,
    this.status,
  });

  factory Levy.fromJson(Map<String, dynamic> json) => Levy(
        id: json['id'] as int,
        description: _firstString(json, ['description', 'levy_type', 'name']),
        period: _firstString(json, ['period', 'levy_period', 'month']),
        amountBilled: _asDouble(json['amount_billed'] ?? json['amount_due'] ?? json['amount']),
        amountPaid: _asDouble(json['amount_paid']),
        amountOwing: _asDouble(json['amount_owing'] ?? json['balance']),
        status: _firstString(json, ['status']),
      );
}

class LevyPayment {
  final int id;
  final double amount;
  final String? reference;
  final DateTime? date;

  const LevyPayment({required this.id, this.amount = 0, this.reference, this.date});

  factory LevyPayment.fromJson(Map<String, dynamic> json) => LevyPayment(
        id: json['id'] as int,
        amount: _asDouble(json['amount']),
        reference: _firstString(json, ['reference', 'reference_number', 'receipt_number']),
        date: DateTime.tryParse(_firstString(json, ['payment_date', 'date', 'created_at']) ?? ''),
      );
}

class LeviesBalance {
  final double totalBilled;
  final double totalPaid;
  final double totalOwing;

  const LeviesBalance({this.totalBilled = 0, this.totalPaid = 0, this.totalOwing = 0});

  factory LeviesBalance.fromJson(Map<String, dynamic> json) {
    final totals = (json['totals'] as Map<String, dynamic>?) ?? const {};
    return LeviesBalance(
      totalBilled: _asDouble(totals['total_billed']),
      totalPaid: _asDouble(totals['total_paid']),
      totalOwing: _asDouble(totals['total_owing']),
    );
  }
}
