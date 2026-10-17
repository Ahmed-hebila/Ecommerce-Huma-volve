import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

/// Gets one page of products for a category.
class GetProductsUseCase
    implements UseCase<List<ProductEntity>, GetProductsParams> {
  GetProductsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Result<List<ProductEntity>>> call(GetProductsParams params) {
    return repository.getProducts(
      categoryId: params.categoryId,
      offset: params.offset,
      limit: params.limit,
    );
  }
}

class GetProductsParams {
  const GetProductsParams({
    required this.categoryId,
    this.offset = 0,
    this.limit = defaultPageSize,
  });

  /// How many products are loaded in each page.
  static const int defaultPageSize = 10;

  final int categoryId;

  /// How many products to skip (the products already loaded).
  final int offset;

  /// The page size.
  final int limit;
}
