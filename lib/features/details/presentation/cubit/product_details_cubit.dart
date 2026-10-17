import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import 'product_details_state.dart';

/// Gives the product details screen its product.
///
/// - Opened from the home list: the product is passed in and shown at once.
/// - Opened from a deep link: only the id is known, so the product is
///   loaded from the API.
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit({
    required this.getProductDetailsUseCase,
    required this.productId,
    ProductEntity? initialProduct,
  }) : super(
         initialProduct != null
             ? ProductDetailsLoaded(initialProduct)
             : ProductDetailsLoading(),
       );

  final GetProductDetailsUseCase getProductDetailsUseCase;
  final int productId;

  /// Loads the product only if it wasn't passed to the screen.
  Future<void> loadIfNeeded() async {
    if (state is ProductDetailsLoaded) return;
    await loadProduct();
  }

  /// Loads the product from the API (also used by "Try again").
  Future<void> loadProduct() async {
    emit(ProductDetailsLoading());
    final result = await getProductDetailsUseCase(
      GetProductDetailsParams(productId: productId),
    );
    if (isClosed) return;
    result.fold(
      (failure) => emit(ProductDetailsError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }
}
