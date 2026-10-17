import '../../../home/domain/entities/product_entity.dart';

abstract class ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsLoaded extends ProductDetailsState {
  ProductDetailsLoaded(this.product);

  final ProductEntity product;
}

class ProductDetailsError extends ProductDetailsState {
  ProductDetailsError(this.errorMessage);

  final String errorMessage;
}
