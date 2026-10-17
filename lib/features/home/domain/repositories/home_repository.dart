import '../../../../core/utils/result.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class HomeRepository {
  Future<Result<List<CategoryEntity>>> getCategories();

  /// Returns one page of the category products:
  /// [limit] products starting after the first [offset] products.
  Future<Result<List<ProductEntity>>> getProducts({
    required int categoryId,
    required int offset,
    required int limit,
  });
}
