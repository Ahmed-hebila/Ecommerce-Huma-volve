/// The user as the app sees it (pure Dart, no JSON or Flutter).
class UserEntity {
  const UserEntity({
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
}
