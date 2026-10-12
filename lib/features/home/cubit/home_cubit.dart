import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../models/category_model.dart';
import '../services/home_service.dart';
import 'home_state.dart';

/// Connects the home screen with [HomeService].
/// The UI only calls these methods and listens to the emitted states.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.homeService) : super(HomeInitial());

  final HomeService homeService;

  List<CategoryModel> categories = [];

  static const String _unexpectedError =
      'Something went wrong. Please try again.';

  /// Increases with every products request, so only the response of the
  /// last tapped category is shown when the user switches quickly.
  int _productsRequestId = 0;

  /// Loads the categories, then the products of the first category.
  Future<void> loadHomeData() async {
    emit(CategoriesLoading());
    try {
      categories = await homeService.getCategories();
      if (isClosed) return;
      emit(CategoriesSuccess(categories));
    } on ApiException catch (e) {
      if (!isClosed) emit(CategoriesError(e.message));
      return;
    } catch (_) {
      if (!isClosed) emit(CategoriesError(_unexpectedError));
      return;
    }

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
    try {
      final products = await homeService.getProducts(categoryId: categoryId);
      if (isClosed || requestId != _productsRequestId) return;
      emit(ProductsSuccess(products));
    } on ApiException catch (e) {
      if (isClosed || requestId != _productsRequestId) return;
      emit(ProductsError(e.message));
    } catch (_) {
      if (isClosed || requestId != _productsRequestId) return;
      emit(ProductsError(_unexpectedError));
    }
  }
}
