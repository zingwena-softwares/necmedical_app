import 'package:dio/dio.dart';
import '../../core/employer_api_client.dart';
import '../../models/employer/auth_models.dart';
import '../../models/employer/employee_model.dart';
import '../../models/employer/invoice_model.dart';
import '../../models/employer/payment_model.dart';
import '../../models/employer/payment_proof_model.dart';
import '../../models/employer/return_models.dart';
import '../../models/employer/statement_models.dart';

class EmployerApiService {
  EmployerApiService(this._client);

  final EmployerApiClient _client;

  Map<String, dynamic> _dataOf(dynamic response) => (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  // ---- Auth ----

  Future<LoginResult> login({required String username, required String password, String deviceName = 'mobile'}) async {
    final response = await _client.post('/auth/login', data: {
      'username': username,
      'password': password,
      'device_name': deviceName,
    });
    return LoginResult.fromJson(_dataOf(response));
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<ProfileResult> profile() async {
    final response = await _client.get('/profile');
    return ProfileResult.fromJson(_dataOf(response));
  }

  // ---- Statements ----

  Future<StatementsResult> statements({required String dateFrom, required String dateTo, required int currency}) async {
    final response = await _client.post('/statements', data: {
      'date_from': dateFrom,
      'date_to': dateTo,
      'currency': currency,
    });
    return StatementsResult.fromJson(_dataOf(response));
  }

  Future<List<int>> statementPdf({required String dateFrom, required String dateTo, required int currency}) {
    return _client.postBytes('/statement/pdf', data: {
      'date_from': dateFrom,
      'date_to': dateTo,
      'currency': currency,
    });
  }

  Future<String> emailStatement({
    required String dateFrom,
    required String dateTo,
    required int currency,
    String? emailTo,
  }) async {
    final response = await _client.post('/statement/email', data: {
      'date_from': dateFrom,
      'date_to': dateTo,
      'currency': currency,
      if (emailTo != null && emailTo.isNotEmpty) 'email_to': emailTo,
    });
    if (response is! Map<String, dynamic>) {
      throw EmployerApiException('The server didn\'t confirm the email was sent. Please try again shortly.');
    }
    return response['message'] as String? ?? 'Statement emailed.';
  }

  // ---- Returns ----

  Future<ReturnsResult> returns({required int year, required int currency}) async {
    final response = await _client.post('/returns', data: {'year': year, 'currency': currency});
    return ReturnsResult.fromJson(_dataOf(response));
  }

  Future<ReturnDetailResult> returnDetails(int rsId) async {
    final response = await _client.post('/returns/details', data: {'rs_id': rsId});
    return ReturnDetailResult.fromJson(_dataOf(response));
  }

  Future<String> submitReturn({
    required int year,
    required int month,
    required int currency,
    required List<ReturnSubmissionItem> items,
  }) async {
    final response = await _client.post('/returns/submit', data: {
      'sub_year': year,
      'sub_month': month,
      'sub_currency': currency,
      'items': items.map((i) => i.toJson()).toList(),
    });
    return (response as Map<String, dynamic>)['message'] as String? ?? 'Return submitted.';
  }

  // ---- Invoices & Payments ----

  Future<InvoicesResult> invoices({required String dateFrom, required String dateTo, required int currency}) async {
    final response = await _client.post('/invoices', data: {
      'date_from': dateFrom,
      'date_to': dateTo,
      'currency': currency,
    });
    return InvoicesResult.fromJson(_dataOf(response));
  }

  Future<PaymentsResult> payments({required String dateFrom, required String dateTo, required int currency}) async {
    final response = await _client.post('/payments', data: {
      'date_from': dateFrom,
      'date_to': dateTo,
      'currency': currency,
    });
    return PaymentsResult.fromJson(_dataOf(response));
  }

  // ---- Employees ----

  Future<EmployeesResult> employees({String? search}) async {
    final response = await _client.post('/employees', data: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return EmployeesResult.fromJson(_dataOf(response));
  }

  Future<String> createEmployee({
    required String employeeId,
    required String name,
    required String surname,
    required String grade,
    required double salary,
  }) async {
    final response = await _client.post('/employees/create', data: {
      'employee_id': employeeId,
      'name': name,
      'surname': surname,
      'grade': grade,
      'salary': salary,
    });
    return (response as Map<String, dynamic>)['message'] as String? ?? 'Employee created.';
  }

  Future<String> updateEmployee({
    required int empId,
    required String employeeId,
    required String name,
    required String surname,
    required String grade,
    required double salary,
  }) async {
    final response = await _client.post('/employees/update', data: {
      'emp_id': empId,
      'employee_id': employeeId,
      'name': name,
      'surname': surname,
      'grade': grade,
      'salary': salary,
    });
    return (response as Map<String, dynamic>)['message'] as String? ?? 'Employee updated.';
  }

  Future<String> deleteEmployee(int empId) async {
    final response = await _client.post('/employees/delete', data: {'emp_id': empId});
    return (response as Map<String, dynamic>)['message'] as String? ?? 'Employee removed.';
  }

  // ---- Payment proofs ----

  Future<PaymentProofsResult> paymentProofs({String? status}) async {
    final response = await _client.post('/payment-proofs', data: {
      if (status != null && status.isNotEmpty) 'status': status,
    });
    return PaymentProofsResult.fromJson(_dataOf(response));
  }

  Future<String> uploadPaymentProof({
    required String paymentDate,
    required int paymentCurrency,
    required double paymentAmount,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'payment_date': paymentDate,
      'payment_currency': paymentCurrency,
      'payment_amount': paymentAmount,
      'payment_proof_file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _client.post('/payment-proofs/upload', data: formData);
    return (response as Map<String, dynamic>)['message'] as String? ?? 'Payment proof uploaded.';
  }
}
