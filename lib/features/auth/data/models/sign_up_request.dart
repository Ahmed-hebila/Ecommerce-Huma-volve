import '../../../../core/constants/api_constants.dart';

/// Body of `POST users/`.
class SignUpRequest {
  const SignUpRequest({
    required this.name,
    required this.email,
    required this.password,
    this.avatar = ApiConstants.defaultAvatar,
  });

  final String name;
  final String email;
  final String password;
  final String avatar;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'avatar': avatar,
  };
}
