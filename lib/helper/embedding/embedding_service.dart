import 'package:flutter/services.dart';

class EmbeddingService {
  static const MethodChannel _embeddingChannel = MethodChannel(
    'embedding_channel',
  );

  Future<bool> initModel(String modelName) async {
    final dir = '/storage/emulated/0/Documents';
    final path = "$dir/$modelName";

    return await _embeddingChannel.invokeMethod("initEmbedder", {"path": path});
  }

  Future<List<dynamic>> embed(String text) async {
    final raw = await _embeddingChannel.invokeMethod("embedText", {
      "text": text,
    });

    return (raw as List).map((e) => e.toDouble()).toList();
  }
}
