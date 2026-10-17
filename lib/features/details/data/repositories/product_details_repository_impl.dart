import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/product_entity.dart';
import '../../domain/repositories/product_details_repository.dart';
import '../datasources/product_details_remote_data_source.dart';

class ProductDetailsRepositoryImpl implements ProductDetailsRepository {
  ProductDetailsRepositoryImpl(this.remoteDataSource);

  final ProductDetailsRemoteDataSource remoteDataSource;

  static const String productNotFoundMessage =
      'This product is not available anymore.';

  @override
  Future<Result<ProductEntity>> getProductDetails(int productId) async {
    final result = await guardResult<ProductEntity>(
      () => remoteDataSource.getProductDetails(productId),
    );
    // A link with an id that doesn't exist: the API answers with 400
    // (EntityNotFoundError) and a long technical message.
    return result.fold<Result<ProductEntity>>(
      (failure) => Result.failure(
        failure.statusCode == 400 || failure.statusCode == 404
            ? Failure(productNotFoundMessage, statusCode: failure.statusCode)
            : failure,
      ),
      (_) => result,
    );
  }
}
