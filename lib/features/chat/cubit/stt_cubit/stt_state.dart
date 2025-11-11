import 'package:equatable/equatable.dart';

abstract class SpeechState extends Equatable {
  const SpeechState();

  @override
  List<Object?> get props => [];
}

class SpeechInitial extends SpeechState {}

class SpeechLoading extends SpeechState {}

class SpeechReady extends SpeechState {}

class SpeechRecognizing extends SpeechState {
  final String text;
  const SpeechRecognizing(this.text);

  @override
  List<Object?> get props => [text];
}

class SpeechStopped extends SpeechState {}

class SpeechError extends SpeechState {
  final String message;
  const SpeechError(this.message);

  @override
  List<Object?> get props => [message];
}
