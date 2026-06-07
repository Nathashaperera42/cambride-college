class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profileImage;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profileImage,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'client',
        phone: json['phone'],
        profileImage: json['profileImage'],
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'profileImage': profileImage,
      };
}
