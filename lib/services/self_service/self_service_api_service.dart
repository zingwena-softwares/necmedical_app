import '../../core/self_service_api_client.dart';
import '../../models/self_service/case_model.dart';
import '../../models/self_service/employer_account_model.dart';
import '../../models/self_service/levy_model.dart';
import '../../models/self_service/reference_models.dart';
import '../../models/self_service/report_model.dart';

class SelfServiceApiService {
  SelfServiceApiService(this._client);

  final SelfServiceApiClient _client;

  Future<SelfServiceLookups> lookups() async {
    final data = await _client.get('/lookups');
    return SelfServiceLookups.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Submits a formal case/dispute against an employer. Only `employer_id`
  /// is documented as required; the rest are optional per the doc's example.
  Future<String> submitCase({
    required int employerId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String complaint,
  }) async {
    final data = await _client.post('/cases', data: {
      'employer_id': employerId,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'complaint': complaint,
    });
    return (data['data'] as Map<String, dynamic>)['case_number'] as String;
  }

  Future<SelfServiceCase> trackCase(String caseNumber) async {
    final data = await _client.get('/cases/track', query: {'case_number': caseNumber.trim().toUpperCase()});
    return SelfServiceCase.fromJson(data['data'] as Map<String, dynamic>);
  }

  /// Submits a complaint/accident/sexual-harassment report. `preset` is the
  /// only required field.
  Future<ReportSubmissionResult> submitReport({
    required String preset,
    String? employeeFirstName,
    String? employeeLastName,
    String? employeePhone,
    String? employeeEmail,
    String? employerName,
    required String complaint,
  }) async {
    final data = await _client.post('/reports', data: {
      'preset': preset,
      if (employeeFirstName != null && employeeFirstName.isNotEmpty) 'employee_first_name': employeeFirstName,
      if (employeeLastName != null && employeeLastName.isNotEmpty) 'employee_last_name': employeeLastName,
      if (employeePhone != null && employeePhone.isNotEmpty) 'employee_phone': employeePhone,
      if (employeeEmail != null && employeeEmail.isNotEmpty) 'employee_email': employeeEmail,
      if (employerName != null && employerName.isNotEmpty) 'employer_name': employerName,
      'complaint': complaint,
    });
    return ReportSubmissionResult.fromJson(data['data'] as Map<String, dynamic>);
  }

  // ---- Employer account (register/login/levies) ----

  Future<(String token, EmployerAccount employer)> registerEmployer({
    required String tradeName,
    required String ownerFullName,
    required String physicalAddress,
    required String necContactName,
    required String necContactEmail,
    required String necContactCell,
    required String email,
    required String password,
  }) async {
    final data = await _client.post('/employers/register', data: {
      'trade_name': tradeName,
      'owner_full_name': ownerFullName,
      'physical_address': physicalAddress,
      'nec_contact_name': necContactName,
      'nec_contact_email': necContactEmail,
      'nec_contact_cell': necContactCell,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    return (data['token'] as String, EmployerAccount.fromJson(data['employer'] as Map<String, dynamic>));
  }

  Future<(String token, EmployerAccount employer)> loginEmployer({
    required String email,
    required String password,
  }) async {
    final data = await _client.post('/employers/login', data: {'email': email, 'password': password});
    return (data['token'] as String, EmployerAccount.fromJson(data['employer'] as Map<String, dynamic>));
  }

  Future<void> logoutEmployer() => _client.post('/employers/logout');

  Future<EmployerAccount> me() async {
    final data = await _client.get('/employers/me');
    return EmployerAccount.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<Levy>> levies() async {
    final data = await _client.get('/levies');
    return ((data['data'] as List?) ?? []).map((e) => Levy.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LeviesBalance> leviesBalance() async {
    final data = await _client.get('/levies/balance');
    return LeviesBalance.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<LevyPayment>> payments() async {
    final data = await _client.get('/payments');
    return ((data['data'] as List?) ?? []).map((e) => LevyPayment.fromJson(e as Map<String, dynamic>)).toList();
  }
}
