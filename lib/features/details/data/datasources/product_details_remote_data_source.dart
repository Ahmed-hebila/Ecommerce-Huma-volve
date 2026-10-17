import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/safe_api_call.dart';
import '../../../home/data/models/product_model.dart';

/// Gets one product from the API.
/// Throws an `ApiException` with a readable message when the request fails.
abstract class ProductDetailsRemoteDataSource {
  Future<ProductModel> getProductDetails(int productId);
}

class ProductDetailsRemoteDataSourceImpl
    implements ProductDetailsRemoteDataSource {
  ProductDetailsRemoteDataSourceImpl(this.dio);

  final Dio dio;

  /// `GET products/{id}`
  @override
  Future<ProductModel> getProductDetails(int productId) {
    return safeApiCall(() async {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.productDetails(productId),
      );
      final data = response.data;
      if (data == null) {
        throw const ApiException('Something went wrong. Please try again.');
      }
      return ProductModel.fromJson(data);
    });
  }
}
