import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/storage_service.dart';
import 'api_exception.dart';

// Paths that legitimately return 401 without meaning "your session expired"
// (e.g. a wrong-password login attempt) — excluded from the global handler.
const _kAuthEndpoints = ['/auth/login', '/auth/register', '/auth/forgot-password', '/auth/reset-password'];

// Configures Dio and attaches the JWT via a request interceptor.
class DioClient {
  final Dio dio;
  final StorageService storage;

  /// Called whenever a request that carried a session token comes back 401
  /// (expired/invalid token or deleted user) — lets callers force a logout
  /// and prompt re-login instead of failing silently.
  final void Function()? onUnauthorized;

  DioClient(this.storage, {this.onUnauthorized})
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        // Token interceptor: inject Authorization header when a token exists.
        onRequest: (options, handler) async {
          final token = await storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          final isAuthEndpoint = _kAuthEndpoints.any((p) => e.requestOptions.path.contains(p));
          if (e.response?.statusCode == 401 && !isAuthEndpoint) {
            onUnauthorized?.call();
          }
          handler.next(e);
        },
      ),
    );
  }

  // Normalise any Dio/unknown error into a readable ApiException.
  ApiException toApiException(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final code = error.response?.statusCode;
      if (data is Map && data['message'] != null) {
        return ApiException(data['message'].toString(), code);
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return ApiException('Cannot reach the server. Check your connection.', code);
      }
      return ApiException('Something went wrong. Please try again.', code);
    }
    return ApiException(error.toString());
  }
}
