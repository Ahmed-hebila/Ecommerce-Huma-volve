import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/product_entity.dart';
import '../repositories/home_repository.dart';

class GetProductsUseCase
    implements UseCase<List<ProductEntity>, GetProductsParams> {
  GetProductsUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Result<List<ProductEntity>>> call(GetProductsParams params) {
    return repository.getProducts(categoryId: params.categoryId);
  }
}

class GetProductsParams {
  const GetProductsParams({required this.categoryId});

  final int categoryId;
}
