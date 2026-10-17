import '../../../../core/utils/result.dart';
import '../../../home/domain/entities/product_entity.dart';

/// What the product details feature can do. Used when the screen only has
/// the product id (for example when it is opened from a deep link).
abstract class ProductDetailsRepository {
  Future<Result<ProductEntity>> getProductDetails(int productId);
}
