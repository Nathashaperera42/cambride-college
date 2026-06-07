import 'user_model.dart';

// Parses the { data: { user, token } } envelope from auth endpoints.
class AuthResult {
  final UserModel user;
  final String token;
  AuthResult({required this.user, required this.token});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? json) as Map<String, dynamic>;
    return AuthResult(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'].toString(),
    );
  }
}
