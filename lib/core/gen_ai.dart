import 'dart:developer';

import 'package:flutter/services.dart';

class GenAI {
  static const MethodChannel _methodChannel = MethodChannel('method_event');
  static const EventChannel _eventChannel = EventChannel('method_channel');

  static Future<String> load(String path) async {
    log('THe model path is : $path');
    return await _methodChannel.invokeMethod('load', path);
  }

  static Future<String> inference(
    String prompt, {
    Map<String, double>? params,
  }) async {
    return await _methodChannel.invokeMethod('inference', {
      'prompt': prompt,
      'params': params,
    });
  }

  static Future<String> unload() async {
    return await _methodChannel.invokeMethod('unload');
  }

  static Stream<String> get tokenStream {
    return _eventChannel.receiveBroadcastStream().map(
      (event) => event.toString(),
    );
  }

  static Future<void> stopGeneration() async {
    await _methodChannel.invokeMethod('stop');
  }
}
