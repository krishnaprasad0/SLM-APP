import 'package:flutter/services.dart';
import 'package:slm_poc/helper/embedding/model/objectbox.g.dart';
import 'package:slm_poc/helper/embedding/product.dart';

class EmbeddingService {
  final Store store;

  static const _channel = MethodChannel("embedding_channel");

  bool _loaded = false;

  EmbeddingService({required this.store});

  // -------------------------------------------------------
  // Load embedding model from Android native side
  // -------------------------------------------------------
  Future<void> init(String modelFolder) async {
    try {
      final ok = await _channel.invokeMethod("loadEmbeddingModel", {
        "folder": modelFolder,
      });

      if (ok == true) {
        _loaded = true;
        print("✅ Embedding model loaded successfully");
      } else {
        print("❌ Embedding model failed to load");
      }
    } catch (e) {
      print("❌ Error loading embedding model: $e");
    }
  }

  // -------------------------------------------------------
  // Generate embedding vector
  // -------------------------------------------------------
  Future<List<double>> generateEmbedding(String text) async {
    if (!_loaded) {
      throw Exception("Embedding model not loaded. Call init() first.");
    }

    final raw = await _channel.invokeMethod("generateEmbedding", {
      "text": text,
    });

    if (raw == null) {
      throw Exception("Native embedding returned null");
    }

    return (raw as List)
        .map((e) => (e as num).toDouble())
        .toList(growable: false);
  }

  // -------------------------------------------------------
  // Save single product
  // -------------------------------------------------------
  Future<int> saveProductWithEmbedding(Product product) async {
    final combined =
        '${product.productName} ${product.productDescription} '
        '${product.brand} ${product.category} ${product.sku} ${product.barcode}';

    final emb = await generateEmbedding(combined);
    product.embedding = emb;

    return store.box<Product>().put(product);
  }

  // -------------------------------------------------------
  // Save All Products (Batch Embedding)
  // -------------------------------------------------------
  Future<void> saveAllProducts(List<Product> products) async {
    final box = store.box<Product>();

    for (var p in products) {
      final combined =
          '${p.productName} '
          '${p.productDescription} '
          '${p.brand} ${p.category} '
          '${p.sku} ${p.barcode}';

      p.embedding = await generateEmbedding(combined);
    }

    box.putMany(products);
  }

  // -------------------------------------------------------
  // Semantic Search (Vector search using ObjectBox)
  // -------------------------------------------------------
  Future<List<Product>> searchSimilar(String query, {int limit = 10}) async {
    final queryEmbedding = await generateEmbedding(query);

    final box = store.box<Product>();

    final qb = box.query(
      Product_.embedding.nearestNeighborsF32(queryEmbedding, limit),
    );

    final q = qb.build();
    final result = q.find();
    q.close();

    return result;
  }
}
