import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import 'models/auth_tokens.dart';
import 'models/sign_up_request.dart';
import 'models/user_model.dart';

/// Talks to the auth endpoints of the API and keeps the session tokens.
///
/// Every public method throws an [ApiException] with a readable message
/// when something goes wrong.
class AuthService {
  AuthService._(this._dio, this._tokenStorage);

  static final AuthService instance = AuthService._(
    ApiClient.instance.dio,
    TokenStorage.instance,
  );

  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// `POST auth/login` and saves the returned tokens.
  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      await _saveTokens(AuthTokens.fromJson(response.data!));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ApiException(
          'Incorrect email or password.',
          statusCode: 401,
        );
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// Creates a new account with `POST users/`, then logs in with it
  /// so the user goes straight into the app.
  Future<UserModel> signUp(SignUpRequest request) async {
    final UserModel user;
    try {
      final isAvailable = await _isEmailAvailable(request.email);
      if (!isAvailable) {
        throw const ApiException('An account with this email already exists.');
      }
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.users,
        data: request.toJson(),
      );
      user = UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }

    await login(email: request.email, password: request.password);
    return user;
  }

  /// `GET auth/profile` for the logged-in user.
  /// If the access token expired, it is refreshed once and the call retried.
  Future<UserModel> getProfile() async {
    try {
      return await _fetchProfile();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && await _refreshTokens()) {
        try {
          return await _fetchProfile();
        } on DioException catch (retryError) {
          throw ApiException.fromDioException(retryError);
        }
      }
      throw ApiException.fromDioException(e);
    }
  }

  Future<bool> isLoggedIn() => _tokenStorage.hasAccessToken();

  Future<void> logout() => _tokenStorage.clear();

  Future<UserModel> _fetchProfile() async {
    final token = await _tokenStorage.readAccessToken();
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.profile,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return UserModel.fromJson(response.data!);
  }

  /// `POST auth/refresh-token`. Returns false (and clears the session)
  /// when the refresh token is missing or no longer valid.
  Future<bool> _refreshTokens() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      await _saveTokens(AuthTokens.fromJson(response.data!));
      return true;
    } on DioException {
      await _tokenStorage.clear();
      return false;
    }
  }

  /// `POST users/is-available` -> `{"isAvailable": true}`
  Future<bool> _isEmailAvailable(String email) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.isEmailAvailable,
      data: {'email': email},
    );
    return response.data?['isAvailable'] as bool? ?? true;
  }

  Future<void> _saveTokens(AuthTokens tokens) {
    return _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }
}
