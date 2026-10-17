import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/network/api_exception.dart';
import 'package:ecommerce_app_huma_volve/core/routing/app_routes.dart';
import 'package:ecommerce_app_huma_volve/core/utils/result.dart';
import 'package:ecommerce_app_huma_volve/features/details/data/datasources/product_details_remote_data_source.dart';
import 'package:ecommerce_app_huma_volve/features/details/data/repositories/product_details_repository_impl.dart';
import 'package:ecommerce_app_huma_volve/features/details/domain/usecases/get_product_details_usecase.dart';
import 'package:ecommerce_app_huma_volve/features/details/presentation/cubit/product_details_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/details/presentation/cubit/product_details_state.dart';
import 'package:ecommerce_app_huma_volve/features/home/data/models/product_model.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product_entity.dart';

const _product = ProductModel(
  id: 5,
  title: 'Classic Shirt',
  price: 30,
  description: 'Cotton',
  images: [],
);

/// Returns [_product] for id 5 and the API "not found" error (400) for any
/// other id, like the Platzi API.
class FakeProductDetailsRemoteDataSource
    implements ProductDetailsRemoteDataSource {
  final List<int> requestedIds = [];
  bool noInternet = false;

  @override
  Future<ProductModel> getProductDetails(int productId) async {
    requestedIds.add(productId);
    if (noInternet) {
      throw const ApiException(
        'No internet connection. Please check your network.',
      );
    }
    if (productId != _product.id) {
      throw const ApiException(
        'Could not find any entity of type "Product"',
        statusCode: 400,
      );
    }
    return _product;
  }
}

/// Answers every Dio request with [responseJson] and remembers the request.
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

ProductDetailsCubit _buildCubit(
  FakeProductDetailsRemoteDataSource dataSource, {
  int productId = 5,
  ProductEntity? initialProduct,
}) {
  return ProductDetailsCubit(
    getProductDetailsUseCase: GetProductDetailsUseCase(
      ProductDetailsRepositoryImpl(dataSource),
    ),
    productId: productId,
    initialProduct: initialProduct,
  );
}

void main() {
  group('Deep links', () {
    test('builds the product link', () {
      expect(
        DeepLinks.product(5).toString(),
        'humavolve://huma-volve.com/product/5',
      );
      expect(AppRoutes.productDetails(5), '/product/5');
    });

    test('reads the product id from the route and from the full link', () {
      expect(AppRoutes.productIdFrom('/product/5'), 5);
      expect(AppRoutes.productIdFrom('/product/12/'), 12);
      expect(AppRoutes.productIdFrom('/product/7?ref=share'), 7);
      expect(
        AppRoutes.productIdFrom('humavolve://huma-volve.com/product/42'),
        42,
      );
    });

    test('ignores routes that are not a product', () {
      expect(AppRoutes.productIdFrom(null), isNull);
      expect(AppRoutes.productIdFrom('/'), isNull);
      expect(AppRoutes.productIdFrom('/product'), isNull);
      expect(AppRoutes.productIdFrom('/product/abc'), isNull);
      expect(AppRoutes.productIdFrom('/product/0'), isNull);
      expect(AppRoutes.productIdFrom('/product/5/reviews'), isNull);
      expect(AppRoutes.productIdFrom('/cart/5'), isNull);
    });
  });

  group('ProductDetailsRemoteDataSource', () {
    test('requests products/{id}', () async {
      final adapter = FakeHttpAdapter({
        'id': 9,
        'title': 'Shoes',
        'price': 50,
        'description': '',
        'images': <String>[],
      });
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/'))
        ..httpClientAdapter = adapter;

      final product = await ProductDetailsRemoteDataSourceImpl(
        dio,
      ).getProductDetails(9);

      expect(adapter.lastRequest?.path, 'products/9');
      expect(product.id, 9);
      expect(product.title, 'Shoes');
    });
  });

  group('ProductDetailsRepository', () {
    test('returns the product', () async {
      final repository = ProductDetailsRepositoryImpl(
        FakeProductDetailsRemoteDataSource(),
      );

      final result = await repository.getProductDetails(5);

      expect(result, isA<SuccessResult<ProductEntity>>());
      expect((result as SuccessResult<ProductEntity>).data.title, 'Classic Shirt');
    });

    test('shows a readable message for a product that does not exist',
        () async {
      final repository = ProductDetailsRepositoryImpl(
        FakeProductDetailsRemoteDataSource(),
      );

      final result = await repository.getProductDetails(999);

      final message = result.fold((failure) => failure.message, (_) => '');
      expect(message, ProductDetailsRepositoryImpl.productNotFoundMessage);
    });
  });

  group('ProductDetailsCubit', () {
    test('shows the product passed from the list without a request',
        () async {
      final dataSource = FakeProductDetailsRemoteDataSource();
      final cubit = _buildCubit(dataSource, initialProduct: _product);

      await cubit.loadIfNeeded();

      expect(cubit.state, isA<ProductDetailsLoaded>());
      expect(dataSource.requestedIds, isEmpty);
      await cubit.close();
    });

    test('loads the product by id when opened from a deep link', () async {
      final dataSource = FakeProductDetailsRemoteDataSource();
      final cubit = _buildCubit(dataSource);
      expect(cubit.state, isA<ProductDetailsLoading>());

      await cubit.loadIfNeeded();

      expect(dataSource.requestedIds, [5]);
      final state = cubit.state as ProductDetailsLoaded;
      expect(state.product.title, 'Classic Shirt');
      await cubit.close();
    });

    test('emits an error and loads again on retry', () async {
      final dataSource = FakeProductDetailsRemoteDataSource()
        ..noInternet = true;
      final cubit = _buildCubit(dataSource);

      await cubit.loadIfNeeded();
      expect(cubit.state, isA<ProductDetailsError>());
      expect(
        (cubit.state as ProductDetailsError).errorMessage,
        contains('internet'),
      );

      dataSource.noInternet = false;
      await cubit.loadProduct();
      expect(cubit.state, isA<ProductDetailsLoaded>());
      await cubit.close();
    });
  });
}
