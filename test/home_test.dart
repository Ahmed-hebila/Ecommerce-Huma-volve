import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/network/api_client.dart';
import 'package:ecommerce_app_huma_volve/core/network/api_exception.dart';
import 'package:ecommerce_app_huma_volve/features/home/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/cubit/home_state.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/category_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/models/product_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/services/home_service.dart';

/// A HomeService that returns fixed data instead of calling the API.
class FakeHomeService extends HomeService {
  FakeHomeService({this.failCategories = false}) : super(ApiClient.instance);

  final bool failCategories;
  final List<int> requestedCategoryIds = [];

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (failCategories) {
      throw const ApiException('No internet connection.');
    }
    return const [
      CategoryModel(id: 1, name: 'Clothes'),
      CategoryModel(id: 2, name: 'Electronics'),
    ];
  }

  @override
  Future<List<ProductModel>> getProducts({required int categoryId}) async {
    requestedCategoryIds.add(categoryId);
    return [
      ProductModel(
        id: categoryId * 10,
        title: 'Product of $categoryId',
        price: 10,
        description: '',
        images: const [],
      ),
    ];
  }
}

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
      final service = FakeHomeService();
      final cubit = HomeCubit(service);

      final states = await _collectStates(cubit, cubit.loadHomeData);

      expect(states.map((s) => s.runtimeType).toList(), [
        CategoriesLoading,
        CategoriesSuccess,
        ProductsLoading,
        ProductsSuccess,
      ]);
      expect((states[1] as CategoriesSuccess).categories.length, 2);
      expect(service.requestedCategoryIds, [1]);
      await cubit.close();
    });

    test('getProducts loads the selected category', () async {
      final service = FakeHomeService();
      final cubit = HomeCubit(service);

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
      final cubit = HomeCubit(FakeHomeService(failCategories: true));

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
