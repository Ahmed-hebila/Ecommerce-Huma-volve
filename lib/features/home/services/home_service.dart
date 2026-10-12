import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Gets the home data (categories and their products) from the API.
/// Throws an [ApiException] with a readable message on failure.
class HomeService {
  HomeService(this.apiClient);

  final ApiClient apiClient;

  /// `GET categories`
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.dio.get<List<dynamic>>(
        ApiConstants.categories,
      );
      final jsonData = response.data ?? [];
      return jsonData
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// `GET categories/{categoryId}/products`
  Future<List<ProductModel>> getProducts({required int categoryId}) async {
    try {
      final response = await apiClient.dio.get<List<dynamic>>(
        ApiConstants.categoryProducts(categoryId),
      );
      final jsonData = response.data ?? [];
      return jsonData
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
