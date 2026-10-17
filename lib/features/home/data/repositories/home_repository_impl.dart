import '../../../../core/error/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this.remoteDataSource);

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<Result<List<CategoryEntity>>> getCategories() {
    return guardResult(remoteDataSource.getCategories);
  }

  @override
  Future<Result<List<ProductEntity>>> getProducts({
    required int categoryId,
    required int offset,
    required int limit,
  }) {
    return guardResult(
      () => remoteDataSource.getProducts(
        categoryId: categoryId,
        offset: offset,
        limit: limit,
      ),
    );
  }
}
