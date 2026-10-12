import 'category_model.dart';

/// One product from `GET categories/{id}/products`.
class ProductModel {
  const ProductModel({
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
  final CategoryModel? category;

  /// The first image, or an empty string if the product has none.
  String get imageUrl => images.isNotEmpty ? images.first : '';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final images = json['images'];
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      category: category is Map<String, dynamic>
          ? CategoryModel.fromJson(category)
          : null,
      images: images is List
          ? images
                .map((e) => _cleanImageUrl(e.toString()))
                .where((url) => url.isNotEmpty)
                .toList()
          : const [],
    );
  }

  /// Some products in the public API have image links saved like
  /// `["https://..."]`, so the brackets and quotes are removed.
  static String _cleanImageUrl(String url) =>
      url.replaceAll(RegExp(r'[\[\]"]'), '').trim();
}
