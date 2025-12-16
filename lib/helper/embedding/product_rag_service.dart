import 'package:slm_poc/helper/embedding/product.dart';

import '../embedding/embedding_service.dart';
import '../embedding/model/objectbox.g.dart';

class ProductRagService {
  final Box<Product> box;
  final EmbeddingService emb;

  ProductRagService({required this.box, required this.emb});

  String _combine(Product p) {
    return "${p.productName}. ${p.brand}. ${p.category}. ${p.productDescription}";
  }

  Future<void> indexAllProducts({bool force = false}) async {
    final products = box.getAll();

    for (final p in products) {
      if (p.embedding.isNotEmpty && !force) continue;

      final t = _combine(p);
      final vector = await emb.embed(t);

      p.embedding = (vector).cast<double>();
      box.put(p);
    }
  }

  Future<List<Product>> search(String query, {int limit = 5}) async {
    final qvec = await emb.embed(query);

    final q = box
        .query(
          Product_.embedding.nearestNeighborsF32(qvec.cast<double>(), limit),
        )
        .build();

    final found = q.find();
    q.close();

    return found;
  }
}
