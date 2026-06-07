import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/storage_service.dart';
import 'api_exception.dart';

// Configures Dio and attaches the JWT via a request interceptor.
class DioClient {
  final Dio dio;
  final StorageService storage;

  DioClient(this.storage)
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
        onError: (e, handler) => handler.next(e),
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
