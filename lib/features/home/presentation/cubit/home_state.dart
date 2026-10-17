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
class ProductsLoading extends HomeState {}

class ProductsSuccess extends HomeState {
  ProductsSuccess(this.products);

  final List<ProductEntity> products;
}

class ProductsError extends HomeState {
  ProductsError(this.errorMessage);

  final String errorMessage;
}
