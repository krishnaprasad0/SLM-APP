class Product {
  final int productId;
  final String productName;
  final String productDescription;
  final double productPrice;
  final int totalStock;
  final String productUnit;
  final String expireDate;
  final String category;
  final String brand;
  final String sku;
  final String barcode;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.totalStock,
    required this.productUnit,
    required this.expireDate,
    required this.category,
    required this.brand,
    required this.sku,
    required this.barcode,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ EMPTY PRODUCT (used when AI can't find a match)
  factory Product.empty() => Product(
    productId: -1,
    productName: "",
    productDescription: "",
    productPrice: 0.0,
    totalStock: 0,
    productUnit: "",
    expireDate: "",
    category: "",
    brand: "",
    sku: "",
    barcode: "",
    createdAt: "",
    updatedAt: "",
  );

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json["product_id"],
    productName: json["product_name"],
    productDescription: json["product_description"],
    productPrice: json["product_price"].toDouble(),
    totalStock: json["total_stock"],
    productUnit: json["product_unit"],
    expireDate: json["expire_date"],
    category: json["category"],
    brand: json["brand"],
    sku: json["sku"],
    barcode: json["barcode"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toMap() => {
    "product_id": productId,
    "product_name": productName,
    "product_description": productDescription,
    "product_price": productPrice,
    "total_stock": totalStock,
    "product_unit": productUnit,
    "expire_date": expireDate,
    "category": category,
    "brand": brand,
    "sku": sku,
    "barcode": barcode,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
