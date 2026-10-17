import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

/// All the states the home screen can be in.
/// Each state is its own class so the UI can check it with `is`.
abstract class HomeState {}

class HomeInitial extends HomeState {}

// Categories
class CategoriesLoading extends HomeState {}

class CategoriesSuccess extends HomeState {
  CategoriesSuccess(this.categories);

  final List<CategoryEntity> categories;
}

class CategoriesError extends HomeState {
  CategoriesError(this.errorMessage);

  final String errorMessage;
}

// Products

/// The first page of the selected category is loading.
class ProductsLoading extends HomeState {}

/// The products loaded so far (all the pages until now).
class ProductsSuccess extends HomeState {
  ProductsSuccess(
    this.products, {
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<ProductEntity> products;

  /// False when the last page came back smaller than the page size,
  /// meaning every product of the category is already loaded.
  final bool hasMore;

  /// True while the next page is loading (a loader shows under the grid).
  final bool isLoadingMore;

  /// The error of the last "load more" request. The loaded products stay
  /// on the screen and the user can try loading the next page again.
  final String? loadMoreError;
}

/// The first page of the selected category failed to load.
class ProductsError extends HomeState {
  ProductsError(this.errorMessage);

  final String errorMessage;
}
