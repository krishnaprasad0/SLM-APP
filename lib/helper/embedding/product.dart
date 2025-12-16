import 'package:objectbox/objectbox.dart';

@Entity()
class Product {
  int id; // ObjectBox ID (autoincrement)

  // From your JSON:
  int productId;
  String productName;
  String productDescription;
  double productPrice;
  int totalStock;
  String productUnit;
  String expireDate;
  String category;
  String brand;
  String sku;
  String barcode;
  String createdAt;
  String updatedAt;

  // 🔹 Vector field for embeddings
  //    Set dimensions to your model's output size (example: 384)
  @HnswIndex(dimensions: 384)
  @Property(type: PropertyType.floatVector)
  List<double> embedding;

  Product({
    this.id = 0,
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
    this.embedding = const [],
  });

  // Optional: helper to create from your JSON map
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json['product_id'],
    productName: json['product_name'],
    productDescription: json['product_description'],
    productPrice: (json['product_price'] as num).toDouble(),
    totalStock: json['total_stock'],
    productUnit: json['product_unit'],
    expireDate: json['expire_date'],
    category: json['category'],
    brand: json['brand'],
    sku: json['sku'],
    barcode: json['barcode'],
    createdAt: json['created_at'],
    updatedAt: json['updated_at'],
  );
}
