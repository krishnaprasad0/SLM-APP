import 'package:slm_poc/helper/embedding/product.dart';
import 'objectbox.g.dart';

class ObjectBox {
  late final Store store;
  late final Box<Product> productBox;

  ObjectBox._create(this.store) {
    productBox = store.box<Product>();
  }

  static Future<ObjectBox> create() async {
    final store = await openStore();
    return ObjectBox._create(store);
  }
}
