import 'package:dio/dio.dart';
import 'constants.dart';

/// Dio wrapper for the Employer Portal API (Ardent Tech, DEVELOPER_INTEGRATION_GUIDE.md).
///
/// Two things this API needs that the generic [ApiClient] doesn't handle:
///  1. Every route requires a trailing slash — the server 301-redirects
///     otherwise, and that redirect silently drops the POST body (confirmed
///     by testing directly against the API), so every request path here is
///     normalized to end with `/`.
///  2. Two auth layers: `X-API-Key` on every request, plus a Bearer token
///     on protected routes once logged in.
class EmployerApiClient {
  EmployerApiClient({void Function()? onUnauthorized}) : _onUnauthorized = onUnauthorized {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.employerApiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'X-API-Key': ApiConstants.employerApiKey,
        },
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio dio;
  String? _accessToken;
  final void Function()? _onUnauthorized;

  void setAccessToken(String? token) => _accessToken = token;

  String _withTrailingSlash(String path) => path.endsWith('/') ? path : '$path/';

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get(_withTrailingSlash(path), queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      throw EmployerApiException.from(e);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final response = await dio.post(_withTrailingSlash(path), data: data);
      return response.data;
    } on DioException catch (e) {
      throw EmployerApiException.from(e);
    }
  }

  /// For endpoints that stream a non-JSON response (e.g. `/statement/pdf`).
  Future<List<int>> postBytes(String path, {Object? data}) async {
    try {
      final response = await dio.post<List<int>>(
        _withTrailingSlash(path),
        data: data,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      throw EmployerApiException.from(e);
    }
  }
}

class EmployerApiException implements Exception {
  EmployerApiException(this.message, {this.statusCode, this.data});

  final String message;
  final int? statusCode;
  final dynamic data;

  factory EmployerApiException.from(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;
    String? serverMessage;
    if (body is Map && body['message'] is String) {
      serverMessage = body['message'] as String;
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return EmployerApiException('Connection timed out. Check your internet connection.', statusCode: statusCode, data: body);
      case DioExceptionType.connectionError:
        return EmployerApiException('No internet connection.', statusCode: statusCode, data: body);
      default:
        break;
    }

    switch (statusCode) {
      case 401:
        return EmployerApiException(serverMessage ?? 'Your session has expired. Please log in again.', statusCode: 401, data: body);
      case 403:
        return EmployerApiException(serverMessage ?? 'You don\'t have permission to do that.', statusCode: 403, data: body);
      case 404:
        return EmployerApiException(serverMessage ?? 'Not found.', statusCode: 404, data: body);
      case 409:
        return EmployerApiException(serverMessage ?? 'This already exists.', statusCode: 409, data: body);
      case 422:
        return EmployerApiException(serverMessage ?? 'Please check the information you entered.', statusCode: 422, data: body);
      case 429:
        return EmployerApiException('Too many requests — please wait a moment and try again.', statusCode: 429, data: body);
      case 500:
        return EmployerApiException('Something went wrong on the server. Please try again shortly.', statusCode: 500, data: body);
      default:
        return EmployerApiException(serverMessage ?? 'Something went wrong. Please try again.', statusCode: statusCode, data: body);
    }
  }

  @override
  String toString() => message;
}
