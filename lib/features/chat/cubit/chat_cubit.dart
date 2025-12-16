import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:slm_poc/core/gen_ai.dart';
import 'package:slm_poc/core/model_list.dart';
import 'package:slm_poc/helper/file_helper.dart';
import '../model/chat_model.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState.initial());

  final StringBuffer _tokenBuffer = StringBuffer();
  StreamSubscription<String>? _tokenSub;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final String _systemPrompt = """
        You are a friendly retail AI assistant for a store.
        Your main job is to help customers with product details, pricing, inventory,
        offers, and related shopping queries.

        You can also engage in light, polite chit-chat when the user talks casually.
        Keep chit-chat short, friendly, and positive.

        Rules:
        - Always show prices in Indian Rupees (₹).
        - Keep all answers brief, clear, and helpful.
        - If you don't know something, say: "I don't know".
        - Do NOT guess or invent product details.
        - Do NOT give long explanations unless the user asks.
        - Maintain a warm, helpful tone suitable for customer interactions.
        """;

  final double? _temperature = 0.7;
  double? _maxLength;
  final double? _lengthPenalty = 1.0;

  /// Loads local model
  Future<void> loadModel(Model modelPath) async {
    emit(state.copyWith(isLoading: true, status: "Loading model..."));
    try {
      final rootIsolateToken = ServicesBinding.rootIsolateToken!;
      final path = await getModelPath();
      final fullPath = "$path/${modelPath.path}";
      log('🧠 Loading model from: $fullPath');

      await Isolate.run(() async {
        BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
        await GenAI.load(fullPath);
      });

      emit(state.copyWith(isLoading: false, status: "✅ Model loaded"));
    } catch (e, st) {
      log('❌ Model load failed: $e\n$st');
      emit(state.copyWith(isLoading: false, error: "Model load failed: $e"));
    }
  }

  Future<void> sendMessage(String text) async {
    log('The user query is : $text');
    if (state.isSending || text.trim().isEmpty) return;
    final userMsg = Message(
      text: text,
      isMine: true,
      id: '',
      timestamp: DateTime.now(),
    );
    final updated = List<Message>.from(state.messages)..add(userMsg);
    emit(state.copyWith(messages: updated, isSending: true, error: null));

    final finalPrompt =
        "<system>$_systemPrompt<|end|><|user|>$text<|end|><|assistant|>";

    final params = <String, double>{};
    if (_temperature != null) params["temperature"] = _temperature;
    if (_maxLength != null) params["max_length"] = _maxLength!;
    if (_lengthPenalty != null) params["length_penalty"] = _lengthPenalty;

    _tokenBuffer.clear();
    _tokenSub?.cancel();

    String lastSpoken = '';
    Timer? debounceTimer;

    _tokenSub = GenAI.tokenStream.listen(
      (token) async {
        _tokenBuffer.write(token);
        final partialText = _tokenBuffer.toString();
        emit(state.copyWith(partialText: partialText));

        debounceTimer?.cancel();
        debounceTimer = Timer(const Duration(milliseconds: 1500), () async {
          final toSpeak = partialText.substring(lastSpoken.length).trim();
          if (toSpeak.isNotEmpty) {
            lastSpoken = partialText;
            await speak(toSpeak);
          }
        });
      },
      onError: (e) {
        emit(state.copyWith(isSending: false, error: e.toString()));
      },
      onDone: () async {
        debounceTimer?.cancel();
        final remaining = _tokenBuffer
            .toString()
            .substring(lastSpoken.length)
            .trim();
        if (remaining.isNotEmpty) await speak(remaining);

        final botMsg = Message(
          text: _tokenBuffer.toString(),
          isMine: false,
          id: '',
          timestamp: DateTime.now(),
        );

        log("Ai response completed:\n $botMsg");
        final msgs = List<Message>.from(state.messages)..add(botMsg);
        emit(state.copyWith(messages: msgs, isSending: false, partialText: ''));
      },
    );

    await GenAI.inference(finalPrompt, params: params);
    final botMsg = Message(
      text: _tokenBuffer.toString(),
      isMine: false,
      id: '',
      timestamp: DateTime.now(),
    );

    final msgs = List<Message>.from(state.messages)..add(botMsg);
    emit(state.copyWith(messages: msgs, isSending: false, partialText: ''));
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLang = prefs.getString('selected_language') ?? "en-IN";

      await _tts.setLanguage(savedLang);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);

      try {
        await _tts.stop();
      } catch (_) {}

      emit(state.copyWith(isSpeaking: true));
      await _tts.speak(text);

      _tts.setCompletionHandler(() {
        emit(state.copyWith(isSpeaking: false));
      });
    } catch (e) {
      log("❌ TTS error: $e");
      emit(state.copyWith(isSpeaking: false, error: "TTS error: $e"));
    }
  }

  /// Reset chat
  void clear() => emit(const ChatState.initial());

  void stopSpeech() async {
    log('🛑 Stopping speech');
    emit(state.copyWith(isSpeaking: false));

    try {
      await _tts.stop(); // stop text-to-speech
      log('✅ TTS stopped successfully');
    } catch (e) {
      log('❌ Error stopping TTS: $e');
    }
    try {
      await _speech.stop();
      log('🎙️ STT stopped successfully');
    } catch (e) {
      log('⚠️ STT stop skipped or failed: $e');
    }
  }

  @override
  Future<void> close() {
    _tokenSub?.cancel();
    _speech.stop();
    _tts.stop();
    GenAI.unload();
    return super.close();
  }
}
