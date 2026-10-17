import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

/// Returns true if a session (access token) is saved on the device.
class CheckAuthStatusUseCase implements UseCase<bool, NoParams> {
  CheckAuthStatusUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Result<bool>> call([NoParams params = const NoParams()]) {
    return repository.isLoggedIn();
  }
}
