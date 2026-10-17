import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/error/failure.dart';
import 'package:ecommerce_app_huma_volve/core/utils/result.dart';
import 'package:ecommerce_app_huma_volve/features/home/data/models/category_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/data/models/product_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/category_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product_entity.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_categories_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_products_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_state.dart';

/// A HomeRepository that returns fixed data instead of calling the API.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({this.failCategories = false});

  final bool failCategories;
  final List<int> requestedCategoryIds = [];

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    if (failCategories) {
      return const Result.failure(Failure('No internet connection.'));
    }
    return const Result.success([
      CategoryEntity(id: 1, name: 'Clothes'),
      CategoryEntity(id: 2, name: 'Electronics'),
    ]);
  }

  @override
  Future<Result<List<ProductEntity>>> getProducts({
    required int categoryId,
  }) async {
    requestedCategoryIds.add(categoryId);
    return Result.success([
      ProductEntity(
        id: categoryId * 10,
        title: 'Product of $categoryId',
        price: 10,
        description: '',
        images: const [],
      ),
    ]);
  }
}

HomeCubit _buildCubit(FakeHomeRepository repository) => HomeCubit(
  getCategoriesUseCase: GetCategoriesUseCase(repository),
  getProductsUseCase: GetProductsUseCase(repository),
);

Future<List<HomeState>> _collectStates(
  HomeCubit cubit,
  Future<void> Function() action,
) async {
  final states = <HomeState>[];
  final subscription = cubit.stream.listen(states.add);
  await action();
  await Future<void>.delayed(Duration.zero);
  await subscription.cancel();
  return states;
}

void main() {
  group('Home models', () {
    test('ProductModel.fromJson reads the API product', () {
      final product = ProductModel.fromJson({
        'id': 4,
        'title': 'Classic T-Shirt',
        'price': 44,
        'description': 'Soft cotton',
        'images': ['["https://i.imgur.com/QkIa5tT.jpeg"]', ''],
        'category': {'id': 1, 'name': 'Clothes', 'image': ''},
      });
      expect(product.id, 4);
      expect(product.title, 'Classic T-Shirt');
      expect(product.price, 44.0);
      expect(product.images, ['https://i.imgur.com/QkIa5tT.jpeg']);
      expect(product.imageUrl, 'https://i.imgur.com/QkIa5tT.jpeg');
      expect(product.category?.name, 'Clothes');
    });

    test('CategoryModel.fromJson', () {
      final category = CategoryModel.fromJson({'id': 2, 'name': 'Shoes'});
      expect(category.id, 2);
      expect(category.name, 'Shoes');
    });
  });

  group('HomeCubit', () {
    test('loadHomeData loads categories then the first category products',
        () async {
      final repository = FakeHomeRepository();
      final cubit = _buildCubit(repository);

      final states = await _collectStates(cubit, cubit.loadHomeData);

      expect(states.map((s) => s.runtimeType).toList(), [
        CategoriesLoading,
        CategoriesSuccess,
        ProductsLoading,
        ProductsSuccess,
      ]);
      expect((states[1] as CategoriesSuccess).categories.length, 2);
      expect(repository.requestedCategoryIds, [1]);
      await cubit.close();
    });

    test('getProducts loads the selected category', () async {
      final repository = FakeHomeRepository();
      final cubit = _buildCubit(repository);

      final states = await _collectStates(
        cubit,
        () => cubit.getProducts(categoryId: 2),
      );

      expect(states.first, isA<ProductsLoading>());
      expect(states.last, isA<ProductsSuccess>());
      expect((states.last as ProductsSuccess).products.first.id, 20);
      await cubit.close();
    });

    test('emits CategoriesError when the request fails', () async {
      final cubit = _buildCubit(FakeHomeRepository(failCategories: true));

      final states = await _collectStates(cubit, cubit.loadHomeData);

      expect(states.last, isA<CategoriesError>());
      expect(
        (states.last as CategoriesError).errorMessage,
        'No internet connection.',
      );
      await cubit.close();
    });
  });
}
