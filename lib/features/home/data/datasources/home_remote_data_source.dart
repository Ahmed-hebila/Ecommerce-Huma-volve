import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/safe_api_call.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Gets the home data (categories and their products) from the API.
/// Throws an `ApiException` with a readable message when a request fails.
abstract class HomeRemoteDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<List<ProductModel>> getProducts({required int categoryId});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl(this.dio);

  final Dio dio;

  /// `GET categories`
  @override
  Future<List<CategoryModel>> getCategories() {
    return safeApiCall(() async {
      final response = await dio.get<List<dynamic>>(ApiConstants.categories);
      final jsonData = response.data ?? [];
      return jsonData
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// `GET categories/{categoryId}/products`
  @override
  Future<List<ProductModel>> getProducts({required int categoryId}) {
    return safeApiCall(() async {
      final response = await dio.get<List<dynamic>>(
        ApiConstants.categoryProducts(categoryId),
      );
      final jsonData = response.data ?? [];
      return jsonData
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }
}
