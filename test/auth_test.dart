import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/network/api_exception.dart';
import 'package:ecommerce_app_huma_volve/core/utils/validators.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/models/auth_tokens.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/models/sign_up_request.dart';
import 'package:ecommerce_app_huma_volve/features/auth/data/models/user_model.dart';

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
    test('AuthTokens.fromJson', () {
      final tokens = AuthTokens.fromJson({
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

    test('SignUpRequest.toJson sends a default avatar', () {
      const request = SignUpRequest(
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
}
