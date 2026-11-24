class Subcategory {
  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final bool isActive;

  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description = '',
    this.isActive = true,
  });

  Subcategory copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return Subcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
