import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/paginated_users.dart';
import '../models/user_model.dart';

class UserRepository {
  final DioClient client;
  UserRepository(this.client);

  // ---- Admin: user management ----
  Future<PaginatedUsers> getUsers({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final res = await client.dio.get(ApiConstants.users, queryParameters: {
        'page': page,
        'limit': limit,
        if (search.isNotEmpty) 'search': search,
      });
      return PaginatedUsers.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    String role = 'client',
  }) async {
    try {
      final res = await client.dio.post(ApiConstants.users, data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final res = await client.dio.put('${ApiConstants.users}/$id', data: data);
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await client.dio.delete('${ApiConstants.users}/$id');
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  // ---- Self: profile ----
  Future<UserModel> getProfile() async {
    try {
      final res = await client.dio.get(ApiConstants.profile);
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await client.dio.put(ApiConstants.profile, data: data);
      return UserModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw client.toApiException(e);
    }
  }

  Future<void> deleteProfile() async {
    try {
      await client.dio.delete(ApiConstants.profile);
    } catch (e) {
      throw client.toApiException(e);
    }
  }
}
