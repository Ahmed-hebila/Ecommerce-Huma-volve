import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../repositories/product_details_repository.dart';

class GetProductDetailsUseCase
    implements UseCase<ProductEntity, GetProductDetailsParams> {
  GetProductDetailsUseCase(this.repository);

  final ProductDetailsRepository repository;

  @override
  Future<Result<ProductEntity>> call(GetProductDetailsParams params) {
    return repository.getProductDetails(params.productId);
  }
}

class GetProductDetailsParams {
  const GetProductDetailsParams({required this.productId});

  final int productId;
}
