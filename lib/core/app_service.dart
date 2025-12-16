import 'package:slm_poc/helper/embedding/embedding_service.dart';
import 'package:slm_poc/helper/embedding/model/objectbox.dart';
import 'package:slm_poc/helper/embedding/model/product_loader.dart';
import 'package:slm_poc/helper/embedding/product_rag_service.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late ObjectBox objectBox;
  late EmbeddingService embedding;
  late ProductRagService rag;

  bool initialized = false;

  Future<void> init() async {
    if (initialized) return;

    // 1. Open ObjectBox
    objectBox = await ObjectBox.create();

    // 2. Init embedding model
    embedding = EmbeddingService();
    await embedding.initModel("Qwen_3_Embedding");

    // 3. Load Product JSON if empty DB
    if (objectBox.productBox.isEmpty()) {
      final products = await ProductProvider.loadFromJson();
      objectBox.productBox.putMany(products);
    }

    // 4. RAG Service
    rag = ProductRagService(box: objectBox.productBox, emb: embedding);

    // 5. Build embeddings
    await rag.indexAllProducts();

    initialized = true;
  }
}
