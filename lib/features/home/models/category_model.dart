/// One category from `GET categories`.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.image = '',
  });

  final int id;
  final String name;
  final String image;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}
