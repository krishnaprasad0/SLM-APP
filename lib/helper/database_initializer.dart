import 'package:shared_preferences/shared_preferences.dart';
import 'package:slm_poc/helper/embedding_helper.dart';
import 'package:slm_poc/helper/embedding/model/product_loader.dart';
import 'package:slm_poc/helper/embedding/model/objectbox.g.dart';

class DatabaseInitializer {
  final Store store;
  final EmbeddingService embeddingService;

  DatabaseInitializer({required this.store, required this.embeddingService});

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final hasInit = prefs.getBool('db_initialized') ?? false;

    if (hasInit) {
      print("📦 Database already initialized");
      return;
    }

    print("⏳ Loading products.json…");
    final products = await ProductProvider.loadFromJson();

    print("⚙️ Generating embeddings…");
    await embeddingService.saveAllProducts(products);

    print("🎉 Product DB initialized with embeddings");

    await prefs.setBool('db_initialized', true);
  }
}
