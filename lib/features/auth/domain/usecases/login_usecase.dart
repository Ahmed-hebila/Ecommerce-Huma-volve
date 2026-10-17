import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<void, LoginParams> {
  LoginUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Result<void>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}

class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}
