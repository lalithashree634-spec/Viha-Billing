class ProductCategory {
  final String id;
  final String code;
  final String name;
  final String hsnCode;
  final double gstPercent;
  final String description;
  final bool isActive;

  const ProductCategory({
    required this.id,
    required this.code,
    required this.name,
    this.hsnCode = '',
    required this.gstPercent,
    this.description = '',
    this.isActive = true,
  });

  ProductCategory copyWith({
    String? id,
    String? code,
    String? name,
    String? hsnCode,
    double? gstPercent,
    String? description,
    bool? isActive,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      hsnCode: hsnCode ?? this.hsnCode,
      gstPercent: gstPercent ?? this.gstPercent,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
