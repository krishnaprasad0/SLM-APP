import 'dart:io';

class Model {
  final String name;
  final String path;
  final List<String> files;

  const Model(this.name, this.path, this.files);
}

class Models {
  static Model? _model;

  // Helper function to avoid repeating base URLs
  static List<String> _buildUrls(String baseUrl, List<String> fileNames) =>
      fileNames.map((file) => '$baseUrl/$file').toList();

  /// 🦙 Llama 3.2 1B
  static final Model llama3_2 = Model(
    "Llama 3.2 1B",
    "llama3_2",
    _buildUrls(
      'https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-ONNX/resolve/main/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4',
      [
        'config.json',
        'genai_config.json',
        'model.onnx',
        'model.onnx.data',
        'special_tokens_map.json',
        'tokenizer.json',
        'tokenizer_config.json',
      ],
    ),
  );

  /// 🧠 Phi 3.5 Mini
  static final Model phi3_5Mini = Model(
    "Phi-3.5-Mini",
    "phi3_5Mini",
    _buildUrls(
      'https://huggingface.co/microsoft/Phi-3.5-mini-instruct-onnx/resolve/main/cpu_and_mobile/cpu-int4-awq-block-128-acc-level-4',
      [
        'config.json',
        'genai_config.json',
        'phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx',
        'phi-3.5-mini-instruct-cpu-int4-awq-block-128-acc-level-4.onnx.data',
        'special_tokens_map.json',
        'tokenizer.json',
        'tokenizer_config.json',
      ],
    ),
  );

  static final Model deepSeek_R1_Distill_ONNX = Model(
    "Qwen 1.5B",
    "DeepSeek_R1_Distill_ONNX",
    _buildUrls(
      // Base path
      'https://huggingface.co/onnxruntime/DeepSeek-R1-Distill-ONNX/resolve/main/deepseek-r1-distill-qwen-1.5B/cpu_and_mobile/cpu-int4-rtn-block-32-acc-level-4',
      [
        // Tokenizer/config files (root)
        'genai_config.json',
        'model.onnx',
        'model.onnx.data',
        'special_tokens_map.json',
        'tokenizer_config.json',
        'tokenizer.json',
      ],
    ),
  );

  /// 📦 Collection of all models
  static final Map<String, Model> all = {
    'llama3_2': llama3_2,
    'phi3_5Mini': phi3_5Mini,
    'DeepSeek_R1_Distill_ONNX': deepSeek_R1_Distill_ONNX,
  };

  /// Initialize default model (platform-aware)
  static void init() {
    _model = Platform.isAndroid ? phi3_5Mini : llama3_2;
  }

  static void setModel(Model m) => _model = m;

  static Model get model {
    _model ??= (Platform.isAndroid ? phi3_5Mini : llama3_2);
    return _model!;
  }

  static Model getModel() {
    init();

    return model;
  }

  static List<Model> get availableModels => [
    llama3_2,
    // phi3_5Mini,
    deepSeek_R1_Distill_ONNX,
  ];
}
