import '../models/category_model.dart';
import '../models/product_model.dart';

/// All the states the home screen can be in.
/// Each state is its own class so the UI can check it with `is`.
abstract class HomeState {}

class HomeInitial extends HomeState {}

// Categories
class CategoriesLoading extends HomeState {}

class CategoriesSuccess extends HomeState {
  CategoriesSuccess(this.categories);

  final List<CategoryModel> categories;
}

class CategoriesError extends HomeState {
  CategoriesError(this.errorMessage);

  final String errorMessage;
}

// Products
class ProductsLoading extends HomeState {}

class ProductsSuccess extends HomeState {
  ProductsSuccess(this.products);

  final List<ProductModel> products;
}

class ProductsError extends HomeState {
  ProductsError(this.errorMessage);

  final String errorMessage;
}
