class Product {
  final String id;
  final String name;
  final String category;
  final String barcode;
  final double price;
  final double costPrice;
  final double gstPercent;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.barcode,
    required this.price,
    required this.costPrice,
    required this.gstPercent,
    required this.stock,
  });
}
