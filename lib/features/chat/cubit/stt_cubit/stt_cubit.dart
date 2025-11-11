import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slm_poc/features/chat/cubit/stt_cubit/stt_state.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechCubit extends Cubit<SpeechState> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  SpeechCubit() : super(SpeechInitial());

  /// Initialize the speech recognizer
  Future<void> initialize() async {
    emit(SpeechLoading());
    try {
      var status = await Permission.microphone.status;

      if (status.isDenied ||
          status.isRestricted ||
          status.isPermanentlyDenied) {
        // Request the permission
        status = await Permission.microphone.request();
      }

      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (status) {
            if (status == 'done') {
              emit(SpeechStopped());
            }
          },
          onError: (error) => debugPrint('Speech error: $error'),
        );

        if (available) {
          emit(SpeechReady());
        } else {
          emit(SpeechError('Speech recognition not available'));
        }
      } else {
        emit(SpeechError('Mic permission denied'));
      }
    } catch (e) {
      emit(SpeechError('Initialization failed: $e'));
    }
  }

  /// Start listening to speech
  Future<void> startListening() async {
    try {
      await _speech.listen(
        onResult: (result) {
          emit(SpeechRecognizing(result.recognizedWords));
        },
      );
    } catch (e) {
      emit(SpeechError('Failed to start listening: $e'));
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speech.stop();
      emit(SpeechStopped());
    } catch (e) {
      emit(SpeechError('Failed to stop listening: $e'));
    }
  }

  /// Return the recognized text (helper function)
  String get recognizedText {
    if (state is SpeechRecognizing) {
      return (state as SpeechRecognizing).text;
    }
    return '';
  }
}
