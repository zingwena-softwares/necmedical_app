import '../core/api_client.dart';
import '../core/constants.dart';

/// Result of a POST to `nec/v1/appointment` — mirrors the response shape
/// of the WordPress snippet: `{success, message}` or
/// `{success: false, error: {code, message, fields}}`.
class AppointmentResult {
  final bool success;
  final String message;
  final Map<String, String> fieldErrors;

  const AppointmentResult({required this.success, required this.message, this.fieldErrors = const {}});
}

class AppointmentService {
  AppointmentService({ApiClient? client}) : _client = client ?? ApiClient(ApiConstants.necApiBaseUrl);

  final ApiClient _client;

  Future<AppointmentResult> submitAppointment({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    try {
      final data = await _client.postJson('/appointment', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'message': message,
      });
      final map = data as Map<String, dynamic>;
      if (map['success'] == true) {
        return AppointmentResult(success: true, message: map['message'] as String? ?? 'Submitted successfully.');
      }
      final error = map['error'] as Map<String, dynamic>?;
      final fields = (error?['fields'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {};
      return AppointmentResult(
        success: false,
        message: error?['message'] as String? ?? 'Something went wrong. Please try again.',
        fieldErrors: fields,
      );
    } on ApiException catch (e) {
      final body = e.data;
      if (body is Map) {
        final error = body['error'] as Map<String, dynamic>?;
        final fields = (error?['fields'] as Map?)?.map((k, v) => MapEntry(k.toString(), v.toString())) ?? {};
        return AppointmentResult(
          success: false,
          message: error?['message'] as String? ?? e.message,
          fieldErrors: fields,
        );
      }
      return AppointmentResult(success: false, message: e.message);
    }
  }
}
