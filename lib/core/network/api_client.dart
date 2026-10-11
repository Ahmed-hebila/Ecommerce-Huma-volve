import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/api_constants.dart';

/// Holds the single [Dio] instance shared by all services.
class ApiClient {
  ApiClient._()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      ) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        responseBody: true,
        compact: true,
        enabled: kDebugMode,
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  final Dio dio;
}
