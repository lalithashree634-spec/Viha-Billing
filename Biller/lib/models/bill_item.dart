import 'product.dart';

class BillItem {
  final Product product;
  int quantity;
  double discount; // In percentage or fixed

  BillItem({
    required this.product,
    this.quantity = 1,
    this.discount = 0.0,
  });

  double get unitPrice => product.price;

  double get subtotal => (unitPrice * quantity) * (1 - (discount / 100));

  double get gstAmount => subtotal * (product.gstPercent / 100);

  double get totalWithGst => subtotal + gstAmount;
}
