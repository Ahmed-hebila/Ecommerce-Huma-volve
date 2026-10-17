import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// What the auth feature can do. The domain layer only knows this contract;
/// the data layer (`AuthRepositoryImpl`) decides how it's done.
abstract class AuthRepository {
  Future<Result<void>> login({required String email, required String password});

  /// Creates the account and logs in with it.
  Future<Result<UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> getProfile();

  Future<Result<bool>> isLoggedIn();

  Future<Result<void>> logout();
}
