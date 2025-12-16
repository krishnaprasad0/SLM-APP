import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:slm_poc/helper/embedding/product.dart';

class ProductProvider {
  static Future<List<Product>> loadFromJson() async {
    final raw = await rootBundle.loadString("assets/db/products.json");
    final list = jsonDecode(raw) as List;
    return list.map((e) => Product.fromJson(e)).toList();
  }
}
