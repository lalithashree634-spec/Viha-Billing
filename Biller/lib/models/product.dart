class Product {
  final String id;
  final String name;
  final String category;
  final String subcategory;
  final String barcode;
  final double price;
  final double costPrice;
  final double gstPercent;
  final int stock;
  final String uom;
  final String hsnCode;
  final String imageUrl;
  final int reorderLevel;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory = '',
    required this.barcode,
    required this.price,
    required this.costPrice,
    required this.gstPercent,
    required this.stock,
    this.uom = 'Pcs',
    this.hsnCode = '',
    this.imageUrl = '',
    this.reorderLevel = 10,
    this.isActive = true,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? subcategory,
    String? barcode,
    double? price,
    double? costPrice,
    double? gstPercent,
    int? stock,
    String? uom,
    String? hsnCode,
    String? imageUrl,
    int? reorderLevel,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      gstPercent: gstPercent ?? this.gstPercent,
      stock: stock ?? this.stock,
      uom: uom ?? this.uom,
      hsnCode: hsnCode ?? this.hsnCode,
      imageUrl: imageUrl ?? this.imageUrl,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      isActive: isActive ?? this.isActive,
    );
  }
}
