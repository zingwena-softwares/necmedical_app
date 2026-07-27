import 'package:dio/dio.dart';

/// Base Dio wrapper used by every API service in the app.
///
/// Each backend (WordPress, Employer Portal, Self Service) gets its own
/// [ApiClient] instance constructed with that backend's base URL, but they
/// all share the same timeouts, headers, logging, and error normalization —
/// add auth/interceptor behavior here once and every service picks it up.
class ApiClient {
  ApiClient(String baseUrl, {Map<String, String>? headers})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Accept': 'application/json', ...?headers},
          ),
        ) {
    dio.interceptors.add(LogInterceptor(requestHeader: false, responseHeader: false));
  }

  final Dio dio;

  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get(path, queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFor(e), statusCode: e.response?.statusCode, data: e.response?.data);
    }
  }

  Future<dynamic> postJson(String path, {Object? data}) async {
    try {
      final response = await dio.post(path, data: data, options: Options(contentType: Headers.jsonContentType));
      return response.data;
    } on DioException catch (e) {
      throw ApiException(_messageFor(e), statusCode: e.response?.statusCode, data: e.response?.data);
    }
  }

  String _messageFor(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your internet connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}).';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.data});

  final String message;
  final int? statusCode;
  /// The raw decoded response body, when the server returned one (e.g. a
  /// 422 validation error with structured per-field detail).
  final dynamic data;

  @override
  String toString() => message;
}
