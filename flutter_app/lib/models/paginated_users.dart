import 'user_model.dart';

class PaginatedUsers {
  final List<UserModel> users;
  final int total;
  final int page;
  final int pages;

  PaginatedUsers({
    required this.users,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory PaginatedUsers.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? json) as Map<String, dynamic>;
    return PaginatedUsers(
      users: (data['users'] as List<dynamic>? ?? [])
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: data['total'] ?? 0,
      page: data['page'] ?? 1,
      pages: data['pages'] ?? 1,
    );
  }
}
