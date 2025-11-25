class CheckoutItem {
  final int productId;
  final String productName;
  final double price;
  final String barcode;
  int quantity;

  CheckoutItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.barcode,
    this.quantity = 1,
  });

  double get total => price * quantity;

  CheckoutItem copyWith({int? quantity}) {
    return CheckoutItem(
      productId: productId,
      productName: productName,
      price: price,
      barcode: barcode,
      quantity: quantity ?? this.quantity,
    );
  }
}
