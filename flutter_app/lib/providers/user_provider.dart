import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'app_providers.dart';

class UserListState {
  final bool loading;
  final List<UserModel> users;
  final int page;
  final int pages;
  final int total;
  final String search;
  final String? error;

  const UserListState({
    this.loading = false,
    this.users = const [],
    this.page = 1,
    this.pages = 1,
    this.total = 0,
    this.search = '',
    this.error,
  });

  UserListState copyWith({
    bool? loading,
    List<UserModel>? users,
    int? page,
    int? pages,
    int? total,
    String? search,
    String? error,
  }) =>
      UserListState(
        loading: loading ?? this.loading,
        users: users ?? this.users,
        page: page ?? this.page,
        pages: pages ?? this.pages,
        total: total ?? this.total,
        search: search ?? this.search,
        error: error,
      );
}

class UserListNotifier extends StateNotifier<UserListState> {
  final Ref _ref;
  UserListNotifier(this._ref) : super(const UserListState()) {
    fetch();
  }

  Future<void> fetch({int? page, String? search}) async {
    final p = page ?? state.page;
    final s = search ?? state.search;
    state = state.copyWith(loading: true);
    try {
      final result =
          await _ref.read(userRepositoryProvider).getUsers(page: p, search: s);
      state = state.copyWith(
        loading: false,
        users: result.users,
        page: result.page,
        pages: result.pages,
        total: result.total,
        search: s,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setSearch(String q) => fetch(page: 1, search: q);
  void nextPage() {
    if (state.page < state.pages) fetch(page: state.page + 1);
  }

  void prevPage() {
    if (state.page > 1) fetch(page: state.page - 1);
  }

  void goToPage(int p) {
    if (p >= 1 && p <= state.pages && p != state.page) fetch(page: p);
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    String role = 'client',
  }) async {
    try {
      await _ref.read(userRepositoryProvider).createUser(
            name: name,
            email: email,
            password: password,
            role: role,
          );
      await fetch(page: 1);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    try {
      await _ref.read(userRepositoryProvider).updateUser(id, data);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _ref.read(userRepositoryProvider).deleteUser(id);
      await fetch();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final userListProvider =
    StateNotifierProvider<UserListNotifier, UserListState>(
        (ref) => UserListNotifier(ref));
