import 'money.dart';

class ReturnRow {
  final int id;
  final DateTime submissionDate;
  final int month;
  final String monthName;
  final int year;
  final int currency;
  final String? currencyLabel;
  final int totalEmployees;
  final double employeeContributionTotal;
  final double employerContributionTotal;
  final double grandTotal;

  ReturnRow({
    required this.id,
    required this.submissionDate,
    required this.month,
    required this.monthName,
    required this.year,
    required this.currency,
    this.currencyLabel,
    required this.totalEmployees,
    required this.employeeContributionTotal,
    required this.employerContributionTotal,
    required this.grandTotal,
  });

  factory ReturnRow.fromJson(Map<String, dynamic> json) {
    return ReturnRow(
      id: json['id'] ?? 0,
      submissionDate: DateTime.tryParse(json['submission_date'] ?? '') ?? DateTime.now(),
      month: json['month'] ?? 0,
      monthName: json['month_name'] ?? '',
      year: json['year'] ?? 0,
      currency: json['currency'] ?? 0,
      currencyLabel: json['currency_label'] as String?,
      totalEmployees: json['total_employees'] ?? 0,
      employeeContributionTotal: asDouble(json['employee_contribution_total']),
      employerContributionTotal: asDouble(json['employer_contribution_total']),
      grandTotal: asDouble(json['grand_total']),
    );
  }
}

class ReturnsSummary {
  final int count;
  final double grandTotal;

  ReturnsSummary({required this.count, required this.grandTotal});

  factory ReturnsSummary.fromJson(Map<String, dynamic> json) {
    return ReturnsSummary(count: json['count'] ?? 0, grandTotal: asDouble(json['grand_total']));
  }
}

class ReturnsResult {
  final ReturnsSummary summary;
  final List<ReturnRow> rows;
  final String? currencyLabel;

  ReturnsResult({required this.summary, required this.rows, this.currencyLabel});

  factory ReturnsResult.fromJson(Map<String, dynamic> json) {
    return ReturnsResult(
      summary: ReturnsSummary.fromJson(json['summary'] as Map<String, dynamic>),
      rows: (json['rows'] as List<dynamic>? ?? []).map((r) => ReturnRow.fromJson(r as Map<String, dynamic>)).toList(),
      currencyLabel: (json['filters'] as Map<String, dynamic>?)?['currency_label'] as String?,
    );
  }
}

class ReturnDetailItem {
  final int id;
  final int sysEmpId;
  final String employeeId;
  final String name;
  final String surname;
  final String grade;
  final double employeeContribution;
  final double employerContribution;
  final double grandTotal;
  final int flagCode;
  final String remarks;

  ReturnDetailItem({
    required this.id,
    required this.sysEmpId,
    required this.employeeId,
    required this.name,
    required this.surname,
    required this.grade,
    required this.employeeContribution,
    required this.employerContribution,
    required this.grandTotal,
    required this.flagCode,
    required this.remarks,
  });

  String get fullName => '$name $surname'.trim();

  factory ReturnDetailItem.fromJson(Map<String, dynamic> json) {
    return ReturnDetailItem(
      id: json['id'] ?? 0,
      sysEmpId: json['sys_emp_id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      name: (json['name'] ?? '').toString().trim(),
      surname: (json['surname'] ?? '').toString().trim(),
      grade: (json['grade'] ?? '').toString().trim(),
      employeeContribution: asDouble(json['employee_contribution']),
      employerContribution: asDouble(json['employer_contribution']),
      grandTotal: asDouble(json['grand_total']),
      flagCode: json['flag_code'] ?? 0,
      remarks: json['remarks'] ?? '',
    );
  }
}

class ReturnDetailResult {
  final ReturnRow header;
  final List<ReturnDetailItem> items;

  ReturnDetailResult({required this.header, required this.items});

  factory ReturnDetailResult.fromJson(Map<String, dynamic> json) {
    return ReturnDetailResult(
      header: ReturnRow.fromJson(json['header'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((i) => ReturnDetailItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single row in a new returns submission — mirrors the API's
/// `items: [{ emp_id, employee_contr, employer_contr }]` shape.
class ReturnSubmissionItem {
  final int empId;
  final double employeeContr;
  final double employerContr;

  ReturnSubmissionItem({required this.empId, required this.employeeContr, required this.employerContr});

  Map<String, dynamic> toJson() => {
        'emp_id': empId,
        'employee_contr': employeeContr,
        'employer_contr': employerContr,
      };
}
