import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/auth_result.dart';

class AuthRepository {
  final DioClient client;
  AuthRepository(this.client);

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String role = 'client',
  }) async {
    try {
      final res = await client.dio.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
      });
      return AuthResult.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      return AuthResult.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
