import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  LogoutUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Result<void>> call([NoParams params = const NoParams()]) {
    return repository.logout();
  }
}
