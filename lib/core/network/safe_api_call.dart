import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Runs an API request and turns any [DioException] into an [ApiException]
/// with a readable message. Used by all the remote data sources.
Future<T> safeApiCall<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    throw ApiException.fromDioException(e);
  }
}
