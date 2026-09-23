import 'package:dio/dio.dart';
import 'constants.dart';

/// Dio wrapper for the Self Service API (selfservice.necmedical.org.zw).
/// The case/report/lookup endpoints are public — no token needed. The
/// employer section (register/login/levies/payments) is per-employer
/// authenticated, so this client also carries an optional bearer token
/// for those calls once an employer signs in.
class SelfServiceApiClient {
  SelfServiceApiClient({void Function()? onUnauthorized}) : _onUnauthorized = onUnauthorized {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.selfServiceApiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
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

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get(path, queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      throw SelfServiceApiException.from(e);
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw SelfServiceApiException.from(e);
    }
  }
}

class SelfServiceApiException implements Exception {
  SelfServiceApiException(this.message, {this.statusCode, this.data, this.fieldErrors});

  final String message;
  final int? statusCode;
  final dynamic data;
  final Map<String, List<String>>? fieldErrors;

  factory SelfServiceApiException.from(DioException e) {
    final statusCode = e.response?.statusCode;
    final body = e.response?.data;
    String? serverMessage;
    Map<String, List<String>>? fieldErrors;
    if (body is Map) {
      if (body['message'] is String) serverMessage = body['message'] as String;
      if (body['errors'] is Map) {
        fieldErrors = (body['errors'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()),
        );
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return SelfServiceApiException('Connection timed out. Check your internet connection.', statusCode: statusCode, data: body);
      case DioExceptionType.connectionError:
        return SelfServiceApiException('No internet connection.', statusCode: statusCode, data: body);
      default:
        break;
    }

    switch (statusCode) {
      case 404:
        return SelfServiceApiException(serverMessage ?? 'Not found.', statusCode: 404, data: body);
      case 422:
        return SelfServiceApiException(serverMessage ?? 'Please check the information you entered.',
            statusCode: 422, data: body, fieldErrors: fieldErrors);
      case 429:
        return SelfServiceApiException('Too many requests — please wait a moment and try again.', statusCode: 429, data: body);
      case 500:
        return SelfServiceApiException('Something went wrong on the server. Please try again shortly.', statusCode: 500, data: body);
      default:
        return SelfServiceApiException(serverMessage ?? 'Something went wrong. Please try again.', statusCode: statusCode, data: body);
    }
  }

  @override
  String toString() => message;
}
