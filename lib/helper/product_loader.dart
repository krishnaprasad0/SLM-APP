import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:slm_poc/helper/product.dart';

class ProductLoader {
  static Future<List<Product>> loadProductsFromAssets() async {
    final jsonStr = await rootBundle.loadString('assets/db/products.json');

    final List<dynamic> list = json.decode(jsonStr);

    return list.map((p) => Product.fromJson(p)).toList();
  }
}
