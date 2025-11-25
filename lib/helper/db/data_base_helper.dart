// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:slm_poc/features/checkout/model/checkout_model.dart';
import 'package:slm_poc/helper/db/models/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("xenie_db.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = join(await getDatabasesPath(), filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE products (
        product_id INTEGER PRIMARY KEY,
        product_name TEXT,
        product_description TEXT,
        product_price REAL,
        total_stock INTEGER,
        product_unit TEXT,
        expire_date TEXT,
        category TEXT,
        brand TEXT,
        sku TEXT,
        barcode TEXT,
        created_at TEXT,
        updated_at TEXT
      );
    """);

    await _insertInitialProducts(db);
  }

  Future _insertInitialProducts(Database db) async {
    final jsonString = await rootBundle.loadString("assets/db/products.json");

    List decoded = jsonDecode(jsonString);

    final batch = db.batch();

    for (var item in decoded) {
      final product = Product.fromJson(item);
      batch.insert(
        "products",
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
    print("✅ Initial product data inserted.");
  }

  Future insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      "products",
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future insertProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();

    for (var p in products) {
      batch.insert(
        "products",
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;

    final result = await db.query("products");

    return result.map((e) => Product.fromJson(e)).toList();
  }

  Future<Product?> getProductByBarcode({required String barcode}) async {
    final db = await database;

    final result = await db.query(
      "products",
      where: "barcode = ?",
      whereArgs: [barcode],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Product.fromJson(result.first);
    }

    return null; // Not found
  }

  Future<void> reduceStockForOrder(List<CheckoutItem> items) async {
    final db = await database;

    final batch = db.batch();

    for (var item in items) {
      batch.rawUpdate(
        '''
      UPDATE products
      SET total_stock = total_stock - ?
      WHERE product_id = ?
    ''',
        [item.quantity, item.productId],
      );
    }

    await batch.commit();
    print("🟢 Stock updated for entire order!");
  }
}
