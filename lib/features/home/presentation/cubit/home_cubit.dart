import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'home_state.dart';

/// Connects the home screen with the home use cases.
/// The UI only calls these methods and listens to the emitted states.
///
/// Products are loaded page by page: the first page when a category is
/// selected, then the next page each time the user scrolls near the end.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.getCategoriesUseCase,
    required this.getProductsUseCase,
    this.pageSize = GetProductsParams.defaultPageSize,
  }) : super(HomeInitial());

  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;

  /// How many products are requested in each page.
  final int pageSize;

  List<CategoryEntity> categories = [];

  /// The products of the selected category loaded so far.
  List<ProductEntity> products = [];

  int? _selectedCategoryId;

  /// Where the next page starts (how many products the API already sent).
  int _nextOffset = 0;
  bool _hasMore = false;
  bool _isLoadingMore = false;

  /// Increases with every first-page request, so only the response of the
  /// last tapped category is shown when the user switches quickly.
  int _productsRequestId = 0;

  /// Loads the categories, then the first page of the first category.
  Future<void> loadHomeData() async {
    emit(CategoriesLoading());
    final result = await getCategoriesUseCase();
    if (isClosed) return;

    final loaded = result.fold(
      (failure) {
        emit(CategoriesError(failure.message));
        return false;
      },
      (data) {
        categories = data;
        emit(CategoriesSuccess(categories));
        return true;
      },
    );
    if (!loaded) return;

    if (categories.isNotEmpty) {
      await getProducts(categoryId: categories.first.id);
    } else {
      _productsRequestId++;
      _selectedCategoryId = null;
      products = [];
      _hasMore = false;
      emit(ProductsSuccess(const []));
    }
  }

  /// Loads the first page of the selected category and forgets the pages
  /// of the previous category.
  Future<void> getProducts({required int categoryId}) async {
    final requestId = ++_productsRequestId;
    _selectedCategoryId = categoryId;
    products = [];
    _nextOffset = 0;
    _hasMore = false;
    _isLoadingMore = false;
    emit(ProductsLoading());

    final result = await getProductsUseCase(
      GetProductsParams(categoryId: categoryId, offset: 0, limit: pageSize),
    );
    // Ignore old responses if the user already tapped another category.
    if (isClosed || requestId != _productsRequestId) return;

    result.fold((failure) => emit(ProductsError(failure.message)), (page) {
      products = page;
      _nextOffset = page.length;
      _hasMore = page.length == pageSize;
      emit(ProductsSuccess(List.unmodifiable(products), hasMore: _hasMore));
    });
  }

  /// Loads the next page of the selected category and adds it under the
  /// products already shown. Does nothing while a page is loading or when
  /// every product is already loaded.
  Future<void> loadMoreProducts() async {
    final categoryId = _selectedCategoryId;
    if (isClosed || categoryId == null || !_hasMore || _isLoadingMore) return;

    final requestId = _productsRequestId;
    _isLoadingMore = true;
    emit(
      ProductsSuccess(
        List.unmodifiable(products),
        hasMore: true,
        isLoadingMore: true,
      ),
    );

    final result = await getProductsUseCase(
      GetProductsParams(
        categoryId: categoryId,
        offset: _nextOffset,
        limit: pageSize,
      ),
    );
    // The user switched category or refreshed while this page was loading.
    if (isClosed || requestId != _productsRequestId) return;
    _isLoadingMore = false;

    result.fold(
      (failure) => emit(
        ProductsSuccess(
          List.unmodifiable(products),
          hasMore: true,
          loadMoreError: failure.message,
        ),
      ),
      (page) {
        _nextOffset += page.length;
        _hasMore = page.length == pageSize;
        // The public API data can change between two pages,
        // so products that are already shown are skipped.
        final loadedIds = products.map((product) => product.id).toSet();
        products = [
          ...products,
          ...page.where((product) => loadedIds.add(product.id)),
        ];
        emit(ProductsSuccess(List.unmodifiable(products), hasMore: _hasMore));
      },
    );
  }
}
