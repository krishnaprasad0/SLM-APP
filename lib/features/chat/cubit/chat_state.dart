import 'package:equatable/equatable.dart';
import '../model/chat_model.dart';

class ChatState extends Equatable {
  final List<Message> messages;
  final bool isSending;
  final bool isLoading;
  final bool isListening; // 🎙️ new
  final bool isSpeaking; // 🗣️ new
  final String status;
  final String? error;
  final String partialText;

  const ChatState({
    required this.messages,
    required this.isSending,
    required this.isLoading,
    required this.isListening,
    required this.isSpeaking,
    required this.status,
    required this.partialText,
    this.error,
  });

  const ChatState.initial()
    : messages = const [],
      isSending = false,
      isLoading = false,
      isListening = false,
      isSpeaking = false,
      status = '',
      partialText = '',
      error = null;

  ChatState copyWith({
    List<Message>? messages,
    bool? isSending,
    bool? isLoading,
    bool? isListening,
    bool? isSpeaking,
    String? status,
    String? error,
    String? partialText,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      isLoading: isLoading ?? this.isLoading,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      status: status ?? this.status,
      error: error,
      partialText: partialText ?? this.partialText,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isSending,
    isLoading,
    isListening,
    isSpeaking,
    status,
    error,
    partialText,
  ];
}
