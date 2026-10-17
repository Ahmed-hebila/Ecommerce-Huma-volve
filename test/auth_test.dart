import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/network/api_exception.dart';
import 'package:ecommerce_app_huma_volve/core/utils/validators.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/models/auth_tokens_model.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/models/sign_up_request_model.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app_huma_volve/features/auth/domain/usecases/login_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/login_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/auth/presentation/cubit/login_state.dart';

DioException _badResponse(int statusCode, dynamic data) {
  final options = RequestOptions(path: 'test');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

/// In-memory replacements for the data sources, so the repository and
/// cubit can be tested without the API or secure storage.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String validPassword = 'changeme';
  bool emailAvailable = true;
  bool expiredAccessToken = false;
  int refreshCalls = 0;

  static const tokens = AuthTokensModel(
    accessToken: 'access',
    refreshToken: 'refresh',
  );
  static const user = UserModel(
    id: 1,
    name: 'Ahmed',
    email: 'ahmed@mail.com',
    role: 'customer',
    avatar: '',
  );

  @override
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    if (password != validPassword) {
      throw const ApiException('Unauthorized', statusCode: 401);
    }
    return tokens;
  }

  @override
  Future<bool> isEmailAvailable(String email) async => emailAvailable;

  @override
  Future<UserModel> signUp(SignUpRequestModel request) async => user;

  @override
  Future<UserModel> getProfile(String accessToken) async {
    if (expiredAccessToken && accessToken == 'access') {
      throw const ApiException('Unauthorized', statusCode: 401);
    }
    return user;
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    refreshCalls++;
    return const AuthTokensModel(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }
}

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens(AuthTokensModel tokens) async {
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<bool> hasAccessToken() async => accessToken != null;

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('john'), isNotNull);
      expect(Validators.email('john@mail'), isNotNull);
      expect(Validators.email('john@mail.com'), isNull);
    });

    test('password', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('changeme'), isNull);
    });

    test('new password only accepts letters and numbers', () {
      expect(Validators.newPassword('abc@123'), isNotNull);
      expect(Validators.newPassword('abc123'), isNull);
    });

    test('name', () {
      expect(Validators.name(' '), isNotNull);
      expect(Validators.name('Ahmed'), isNull);
    });
  });

  group('Models', () {
    test('AuthTokensModel.fromJson', () {
      final tokens = AuthTokensModel.fromJson({
        'access_token': 'access',
        'refresh_token': 'refresh',
      });
      expect(tokens.accessToken, 'access');
      expect(tokens.refreshToken, 'refresh');
    });

    test('UserModel.fromJson', () {
      final user = UserModel.fromJson({
        'id': 1,
        'email': 'john@mail.com',
        'name': 'Jhon',
        'role': 'customer',
        'avatar': 'https://i.imgur.com/LDOO4Qs.jpg',
      });
      expect(user.id, 1);
      expect(user.name, 'Jhon');
      expect(user.email, 'john@mail.com');
    });

    test('SignUpRequestModel.toJson sends a default avatar', () {
      const request = SignUpRequestModel(
        name: 'Ahmed',
        email: 'ahmed@mail.com',
        password: 'abc123',
      );
      expect(request.toJson()['avatar'], isNotEmpty);
    });
  });

  group('ApiException', () {
    test('joins validation messages from the API', () {
      final exception = ApiException.fromDioException(
        _badResponse(400, {
          'message': ['email must be an email', 'avatar must be a URL address'],
          'statusCode': 400,
        }),
      );
      expect(
        exception.message,
        'Email must be an email\nAvatar must be a URL address',
      );
      expect(exception.statusCode, 400);
    });

    test('maps 401 to an expired session message', () {
      final exception = ApiException.fromDioException(
        _badResponse(401, {'message': 'Unauthorized', 'statusCode': 401}),
      );
      expect(exception.statusCode, 401);
      expect(exception.message, contains('log in again'));
    });

    test('maps connection errors', () {
      final exception = ApiException.fromDioException(
        DioException(
          requestOptions: RequestOptions(path: 'test'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(exception.message, contains('internet'));
    });
  });

  group('AuthRepositoryImpl', () {
    late FakeAuthRemoteDataSource remote;
    late FakeAuthLocalDataSource local;
    late AuthRepositoryImpl repository;

    setUp(() {
      remote = FakeAuthRemoteDataSource();
      local = FakeAuthLocalDataSource();
      repository = AuthRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );
    });

    test('login saves the tokens', () async {
      final result = await repository.login(
        email: 'ahmed@mail.com',
        password: 'changeme',
      );
      expect(result.isSuccess, isTrue);
      expect(local.accessToken, 'access');
      expect((await repository.isLoggedIn()).fold((_) => false, (v) => v),
          isTrue);
    });

    test('wrong password returns a readable failure', () async {
      final result = await repository.login(
        email: 'ahmed@mail.com',
        password: 'wrong123',
      );
      final message = result.fold((failure) => failure.message, (_) => '');
      expect(message, 'Incorrect email or password.');
      expect(local.accessToken, isNull);
    });

    test('sign up fails when the email is already used', () async {
      remote.emailAvailable = false;
      final result = await repository.signUp(
        name: 'Ahmed',
        email: 'ahmed@mail.com',
        password: 'abc123',
      );
      final message = result.fold((failure) => failure.message, (_) => '');
      expect(message, contains('already exists'));
    });

    test('getProfile refreshes an expired token once', () async {
      await local.saveTokens(FakeAuthRemoteDataSource.tokens);
      remote.expiredAccessToken = true;

      final result = await repository.getProfile();

      expect(result.isSuccess, isTrue);
      expect(remote.refreshCalls, 1);
      expect(local.accessToken, 'new-access');
    });

    test('logout clears the tokens', () async {
      await local.saveTokens(FakeAuthRemoteDataSource.tokens);
      await repository.logout();
      expect(local.accessToken, isNull);
    });
  });

  group('LoginCubit', () {
    test('emits Loading then Failure for a wrong password', () async {
      final repository = AuthRepositoryImpl(
        remoteDataSource: FakeAuthRemoteDataSource(),
        localDataSource: FakeAuthLocalDataSource(),
      );
      final cubit = LoginCubit(LoginUseCase(repository));
      final states = <LoginState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.login(email: 'ahmed@mail.com', password: 'wrong123');
      await Future<void>.delayed(Duration.zero);

      expect(states.first, isA<LoginLoading>());
      expect(states.last, isA<LoginFailure>());
      await subscription.cancel();
      await cubit.close();
    });
  });
}
