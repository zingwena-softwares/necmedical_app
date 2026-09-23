import 'dart:convert';

class EmployeeDetails {
  final String? nationalId;
  final String? email;
  final String? phoneNumber;
  final String? occupation;

  const EmployeeDetails({this.nationalId, this.email, this.phoneNumber, this.occupation});

  factory EmployeeDetails.fromRaw(dynamic raw) {
    if (raw is! String || raw.isEmpty) return const EmployeeDetails();
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return EmployeeDetails(
        nationalId: json['national_id'] as String?,
        email: json['email'] as String?,
        phoneNumber: json['phone_number'] as String?,
        occupation: json['occupation'] as String?,
      );
    } catch (_) {
      return const EmployeeDetails();
    }
  }
}

/// A case as returned by `POST /cases` (just the number) or
/// `GET /cases/track` (the full record).
class SelfServiceCase {
  final int id;
  final String caseNumber;
  final String employeeNames;
  final EmployeeDetails employeeDetails;
  final String? natureCase;
  final String? complaint;
  final String? masterStatus;
  final String? employerTradeName;
  final String? officerComments;
  final DateTime? createdAt;

  const SelfServiceCase({
    required this.id,
    required this.caseNumber,
    required this.employeeNames,
    required this.employeeDetails,
    this.natureCase,
    this.complaint,
    this.masterStatus,
    this.employerTradeName,
    this.officerComments,
    this.createdAt,
  });

  factory SelfServiceCase.fromJson(Map<String, dynamic> json) => SelfServiceCase(
        id: json['id'] as int,
        caseNumber: json['case_number'] as String? ?? '',
        employeeNames: json['employee_names'] as String? ?? '',
        employeeDetails: EmployeeDetails.fromRaw(json['employees_details']),
        natureCase: json['nature_case'] as String?,
        complaint: json['complaint'] as String?,
        masterStatus: json['master_status'] as String?,
        employerTradeName: (json['employer'] as Map<String, dynamic>?)?['trade_name'] as String?,
        officerComments: json['officer_comments'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );
}
