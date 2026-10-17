import 'category_entity.dart';

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    this.category,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final CategoryEntity? category;

  /// The first image, or an empty string if the product has none.
  String get imageUrl => images.isNotEmpty ? images.first : '';
}
