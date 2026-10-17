import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/category_entity.dart';
import '../repositories/home_repository.dart';

class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  GetCategoriesUseCase(this.repository);

  final HomeRepository repository;

  @override
  Future<Result<List<CategoryEntity>>> call([
    NoParams params = const NoParams(),
  ]) {
    return repository.getCategories();
  }
}
