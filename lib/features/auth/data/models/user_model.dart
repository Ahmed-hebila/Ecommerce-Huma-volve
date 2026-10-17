import '../../domain/entities/user_entity.dart';

/// [UserEntity] + JSON parsing for `POST users/` and `GET auth/profile`.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.avatar,
  });

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
