import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'app_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Set to true after a logout that should trigger the login modal on the
/// public site. RootShell listens and resets it after showing the modal.
final pendingLoginModalProvider = StateProvider<bool>((ref) => false);

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool loading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.loading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool? loading,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        loading: loading ?? this.loading,
        error: error, // intentionally reset unless explicitly provided
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthNotifier(this._ref) : super(const AuthState()) {
    _bootstrap();
  }

  // Auto-login: if a stored token resolves to a profile, mark authenticated.
  Future<void> _bootstrap() async {
    final storage = _ref.read(storageServiceProvider);
    final token = await storage.readToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _ref.read(userRepositoryProvider).getProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await storage.clear();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true);
    try {
      final result = await _ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await _ref.read(storageServiceProvider).saveToken(result.token);
      state = state.copyWith(
        loading: false,
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String role = 'client',
  }) async {
    state = state.copyWith(loading: true);
    try {
      final result = await _ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            role: role,
          );
      await _ref.read(storageServiceProvider).saveToken(result.token);
      state = state.copyWith(
        loading: false,
        status: AuthStatus.authenticated,
        user: result.user,
      );
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(storageServiceProvider).clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void setUser(UserModel user) => state = state.copyWith(user: user);
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
