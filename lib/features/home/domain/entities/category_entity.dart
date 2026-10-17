class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.image = '',
  });

  final int id;
  final String name;
  final String image;
}
