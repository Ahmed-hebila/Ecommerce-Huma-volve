import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/error/failure.dart';
import 'package:ecommerce_app_huma_volve/core/utils/result.dart';
import 'package:ecommerce_app_huma_volve/features/home/data/datasources/home_remote_data_source.dart';
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
/// Every category has [productsPerCategory] products, returned page by page.
class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({
    this.failCategories = false,
    this.productsPerCategory = 25,
  });

  final bool failCategories;
  final int productsPerCategory;

  /// Makes the next products request fail (for example the second page).
  bool failNextProducts = false;

  final List<({int categoryId, int offset, int limit})> productRequests = [];

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
    required int offset,
    required int limit,
  }) async {
    productRequests.add((categoryId: categoryId, offset: offset, limit: limit));
    if (failNextProducts) {
      failNextProducts = false;
      return const Result.failure(Failure('No internet connection.'));
    }
    final end = min(offset + limit, productsPerCategory);
    return Result.success([
      for (var i = offset; i < end; i++)
        ProductEntity(
          id: categoryId * 1000 + i,
          title: 'Product $i of $categoryId',
          price: 10,
          description: '',
          images: const [],
        ),
    ]);
  }
}

/// Answers every Dio request with [responseJson] and remembers the request,
/// so the data source can be tested without the internet.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.responseJson);

  final Object responseJson;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(responseJson),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

HomeCubit _buildCubit(FakeHomeRepository repository) => HomeCubit(
  getCategoriesUseCase: GetCategoriesUseCase(repository),
  getProductsUseCase: GetProductsUseCase(repository),
  pageSize: 10,
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

  group('HomeRemoteDataSource', () {
    test('sends offset and limit to get one page of products', () async {
      final adapter = FakeHttpAdapter([
        {
          'id': 7,
          'title': 'Shirt',
          'price': 15,
          'description': '',
          'images': <String>[],
          'category': {'id': 3, 'name': 'Clothes'},
        },
      ]);
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
        ..httpClientAdapter = adapter;

      final products = await HomeRemoteDataSourceImpl(
        dio,
      ).getProducts(categoryId: 3, offset: 20, limit: 10);

      expect(adapter.lastRequest?.path, 'categories/3/products');
      expect(adapter.lastRequest?.queryParameters, {'offset': 20, 'limit': 10});
      expect(products.single.title, 'Shirt');
    });
  });

  group('HomeCubit', () {
    test('loadHomeData loads categories then the first page', () async {
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
      final products = states.last as ProductsSuccess;
      expect(products.products.length, 10);
      expect(products.hasMore, isTrue);
      expect(repository.productRequests, [
        (categoryId: 1, offset: 0, limit: 10),
      ]);
      await cubit.close();
    });

    test('getProducts loads the first page of the selected category', () async {
      final repository = FakeHomeRepository();
      final cubit = _buildCubit(repository);

      final states = await _collectStates(
        cubit,
        () => cubit.getProducts(categoryId: 2),
      );

      expect(states.first, isA<ProductsLoading>());
      expect(states.last, isA<ProductsSuccess>());
      expect((states.last as ProductsSuccess).products.first.id, 2000);
      await cubit.close();
    });

    test('loadMoreProducts adds the next page under the loaded one', () async {
      final repository = FakeHomeRepository();
      final cubit = _buildCubit(repository);
      await cubit.getProducts(categoryId: 1);

      final states = await _collectStates(cubit, cubit.loadMoreProducts);

      expect(states.length, 2);
      expect((states.first as ProductsSuccess).isLoadingMore, isTrue);
      final loaded = states.last as ProductsSuccess;
      expect(loaded.isLoadingMore, isFalse);
      expect(loaded.products.length, 20);
      expect(loaded.products.first.id, 1000);
      expect(loaded.products.last.id, 1019);
      expect(loaded.hasMore, isTrue);
      expect(repository.productRequests.last, (
        categoryId: 1,
        offset: 10,
        limit: 10,
      ));
      await cubit.close();
    });

    test('stops loading when the last page is smaller than the page size',
        () async {
      final repository = FakeHomeRepository(productsPerCategory: 25);
      final cubit = _buildCubit(repository);
      await cubit.getProducts(categoryId: 1);
      await cubit.loadMoreProducts();
      await cubit.loadMoreProducts();

      final last = cubit.state as ProductsSuccess;
      expect(last.products.length, 25);
      expect(last.hasMore, isFalse);

      // Nothing else to load: no request and no new state.
      final states = await _collectStates(cubit, cubit.loadMoreProducts);
      expect(states, isEmpty);
      expect(repository.productRequests.length, 3);
      await cubit.close();
    });

    test('ignores a second load more while a page is loading', () async {
      final repository = FakeHomeRepository();
      final cubit = _buildCubit(repository);
      await cubit.getProducts(categoryId: 1);

      await Future.wait([cubit.loadMoreProducts(), cubit.loadMoreProducts()]);

      expect(repository.productRequests.length, 2);
      expect((cubit.state as ProductsSuccess).products.length, 20);
      await cubit.close();
    });

    test('keeps the loaded products when the next page fails', () async {
      final repository = FakeHomeRepository();
      final cubit = _buildCubit(repository);
      await cubit.getProducts(categoryId: 1);

      repository.failNextProducts = true;
      await cubit.loadMoreProducts();

      final failed = cubit.state as ProductsSuccess;
      expect(failed.products.length, 10);
      expect(failed.loadMoreError, 'No internet connection.');
      expect(failed.hasMore, isTrue);

      // Trying again loads the same page.
      await cubit.loadMoreProducts();
      final loaded = cubit.state as ProductsSuccess;
      expect(loaded.products.length, 20);
      expect(loaded.loadMoreError, isNull);
      expect(repository.productRequests.last.offset, 10);
      await cubit.close();
    });

    test('drops a page that arrives after the user changed category',
        () async {
      final repository = FakeHomeRepository();
      final cubit = _buildCubit(repository);
      await cubit.getProducts(categoryId: 1);

      final oldPage = cubit.loadMoreProducts();
      await cubit.getProducts(categoryId: 2);
      await oldPage;

      final state = cubit.state as ProductsSuccess;
      expect(state.products.length, 10);
      expect(state.products.every((p) => p.id ~/ 1000 == 2), isTrue);
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
