import 'package:dio/dio.dart';

/// A readable error that the UI can show directly to the user.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'The connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No internet connection. Please check your network.',
        );
      case DioExceptionType.badCertificate:
        return const ApiException('Could not create a secure connection.');
      case DioExceptionType.cancel:
        return const ApiException('The request was cancelled.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ApiException(
          _messageFromResponse(error.response?.data, statusCode),
          statusCode: statusCode,
        );
      case DioExceptionType.unknown:
        return const ApiException('Something went wrong. Please try again.');
    }
  }

  /// The API returns errors like:
  /// `{"message": ["email must be an email"], "statusCode": 400}`
  /// or `{"message": "Unauthorized", "statusCode": 401}`.
  static String _messageFromResponse(dynamic data, int? statusCode) {
    if (statusCode == 401) {
      return 'Your session has expired. Please log in again.';
    }
    if (data is Map) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.map((e) => _capitalize(e.toString())).join('\n');
      }
      if (message is String && message.isNotEmpty) {
        return _capitalize(message);
      }
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  @override
  String toString() => message;
}
