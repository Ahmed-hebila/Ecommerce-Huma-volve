import '../../../../core/utils/result.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class HomeRepository {
  Future<Result<List<CategoryEntity>>> getCategories();

  Future<Result<List<ProductEntity>>> getProducts({required int categoryId});
}
