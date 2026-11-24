class Subcategory {
  final String id;
  final String categoryId;
  final String categoryName;
  final String code;
  final String name;
  final String description;
  final bool isActive;

  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.code,
    required this.name,
    this.description = '',
    this.isActive = true,
  });

  Subcategory copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    String? code,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return Subcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
