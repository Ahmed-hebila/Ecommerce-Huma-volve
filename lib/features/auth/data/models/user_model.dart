/// A user returned by `POST users/` and `GET auth/profile`.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatar,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String avatar;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
      avatar: json['avatar'] as String? ?? '',
    );
  }
}
