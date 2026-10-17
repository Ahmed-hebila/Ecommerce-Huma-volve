import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/safe_api_call.dart';
import '../models/auth_tokens_model.dart';
import '../models/sign_up_request_model.dart';
import '../models/user_model.dart';

/// Talks to the auth endpoints of the API.
/// Throws an `ApiException` with a readable message when a request fails.
abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  });

  Future<bool> isEmailAvailable(String email);

  Future<UserModel> signUp(SignUpRequestModel request);

  Future<UserModel> getProfile(String accessToken);

  Future<AuthTokensModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this.dio);

  final Dio dio;

  /// `POST auth/login`
  @override
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) {
    return safeApiCall(() async {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthTokensModel.fromJson(response.data!);
    });
  }

  /// `POST users/is-available` -> `{"isAvailable": true}`
  @override
  Future<bool> isEmailAvailable(String email) {
    return safeApiCall(() async {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.isEmailAvailable,
        data: {'email': email},
      );
      return response.data?['isAvailable'] as bool? ?? true;
    });
  }

  /// `POST users/`
  @override
  Future<UserModel> signUp(SignUpRequestModel request) {
    return safeApiCall(() async {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.users,
        data: request.toJson(),
      );
      return UserModel.fromJson(response.data!);
    });
  }

  /// `GET auth/profile`
  @override
  Future<UserModel> getProfile(String accessToken) {
    return safeApiCall(() async {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.profile,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return UserModel.fromJson(response.data!);
    });
  }

  /// `POST auth/refresh-token`
  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) {
    return safeApiCall(() async {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      return AuthTokensModel.fromJson(response.data!);
    });
  }
}
