import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetProfileUseCase implements UseCase<UserEntity, NoParams> {
  GetProfileUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Result<UserEntity>> call([NoParams params = const NoParams()]) {
    return repository.getProfile();
  }
}
