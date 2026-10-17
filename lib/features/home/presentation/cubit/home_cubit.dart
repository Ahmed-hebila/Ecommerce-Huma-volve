import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'home_state.dart';

/// Connects the home screen with the home use cases.
/// The UI only calls these methods and listens to the emitted states.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.getCategoriesUseCase,
    required this.getProductsUseCase,
  }) : super(HomeInitial());

  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductsUseCase getProductsUseCase;

  List<CategoryEntity> categories = [];

  /// Increases with every products request, so only the response of the
  /// last tapped category is shown when the user switches quickly.
  int _productsRequestId = 0;

  /// Loads the categories, then the products of the first category.
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
      emit(ProductsSuccess([]));
    }
  }

  /// Loads the products of the selected category.
  Future<void> getProducts({required int categoryId}) async {
    final requestId = ++_productsRequestId;
    emit(ProductsLoading());
    final result = await getProductsUseCase(
      GetProductsParams(categoryId: categoryId),
    );
    // Ignore old responses if the user already tapped another category.
    if (isClosed || requestId != _productsRequestId) return;
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsSuccess(products)),
    );
  }
}
