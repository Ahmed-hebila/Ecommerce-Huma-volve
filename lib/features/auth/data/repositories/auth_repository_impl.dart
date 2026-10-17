import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/sign_up_request_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    final result = await guardResult(() async {
      final tokens = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.saveTokens(tokens);
    });
    // The API answers a wrong email/password with 401.
    return result.fold<Result<void>>(
      (failure) => Result.failure(
        failure.statusCode == 401
            ? const Failure('Incorrect email or password.', statusCode: 401)
            : failure,
      ),
      (_) => result,
    );
  }

  @override
  Future<Result<UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return guardResult(() async {
      final isAvailable = await remoteDataSource.isEmailAvailable(email);
      if (!isAvailable) {
        throw const ApiException('An account with this email already exists.');
      }
      final user = await remoteDataSource.signUp(
        SignUpRequestModel(name: name, email: email, password: password),
      );
      // Log in with the new account so the user goes straight into the app.
      final tokens = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await localDataSource.saveTokens(tokens);
      return user;
    });
  }

  @override
  Future<Result<UserEntity>> getProfile() {
    return guardResult(() async {
      try {
        return await _fetchProfile();
      } on ApiException catch (e) {
        // The access token expired: refresh it once and try again.
        if (e.statusCode == 401 && await _refreshTokens()) {
          return _fetchProfile();
        }
        rethrow;
      }
    });
  }

  @override
  Future<Result<bool>> isLoggedIn() {
    return guardResult(localDataSource.hasAccessToken);
  }

  @override
  Future<Result<void>> logout() {
    return guardResult(localDataSource.clearTokens);
  }

  Future<UserModel> _fetchProfile() async {
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ApiException(
        'Your session has expired. Please log in again.',
        statusCode: 401,
      );
    }
    return remoteDataSource.getProfile(accessToken);
  }

  /// Returns false (and clears the session) when the refresh token is
  /// missing or no longer valid.
  Future<bool> _refreshTokens() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final tokens = await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveTokens(tokens);
      return true;
    } on ApiException {
      await localDataSource.clearTokens();
      return false;
    }
  }
}
