import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slm_poc/core/app_service.dart';
import 'package:slm_poc/core/gen_ai.dart';
import 'package:slm_poc/core/model_list.dart';
import 'package:slm_poc/features/chat/cubit/chat_cubit.dart';
import 'package:slm_poc/features/chat/cubit/chat_state.dart';
import 'package:slm_poc/features/chat/cubit/stt_cubit/stt_cubit.dart';
import 'package:slm_poc/features/chat/cubit/stt_cubit/stt_state.dart';
import 'package:slm_poc/features/chat/model/chat_model.dart';
import 'package:slm_poc/features/chat/widget/message_widget.dart';
import 'package:slm_poc/helper/language_helper.dart';

final rag = AppServices.instance.rag;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Model model;
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model = ModalRoute.of(context)!.settings.arguments as Model;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadModel(model);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    final text = _controller.text.trim();

    if (text.isEmpty) return;
    // searchProduct(query: text);
    context.read<ChatCubit>().sendMessage(text);

    _controller.clear();
  }

  void searchProduct({required String query}) async {
    final results = await rag.search(query);
    inspect(results);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.error != null && state.error!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }

        if (state.status.isNotEmpty &&
            state.isListening &&
            _controller.text != state.status) {
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Chat - ${model.name}'),
            centerTitle: true,
            actions: [
              BlocBuilder<LanguageCubit, String>(
                builder: (context, lang) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/settingsPage');
                        },
                        child: Text(
                          lang,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => context.read<ChatCubit>().clear(),
              ),
            ],
          ),

          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(child: _buildMessages(state)),
                  const Divider(height: 1),
                  _buildInputArea(context, state),
                ],
              ),

              // 🧠 Loading overlay when model is initializing
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading model...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessages(ChatState state) {
    final messages = [...state.messages];

    // Add partial streaming message if available
    if (state.partialText.isNotEmpty) {
      messages.add(
        Message(
          text: state.partialText,
          isMine: false,
          id: 'streaming',
          timestamp: DateTime.now(),
        ),
      );
    }

    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Say hi 👋',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == messages.length - 1 &&
            state.isSending &&
            state.partialText.isEmpty) {
          return Text('Thinking....');
        }
        return MessageBubble(message: messages[index]);
      },
    );
  }

  Widget _buildInputArea(BuildContext context, ChatState state) {
    final chatCubit = context.read<ChatCubit>();
    final speechCubit = context.read<SpeechCubit>();

    return BlocConsumer<SpeechCubit, SpeechState>(
      listener: (context, speechState) {
        if (speechState is SpeechRecognizing) {
          // 👂 Update text field live while speaking
          _controller.text = speechState.text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        } else if (speechState is SpeechStopped) {
          // 🛑 Once stopped, send the recognized text automatically (optional)

          if (_controller.text.trim().isNotEmpty) {
            _send(context);
          }
        } else if (speechState is SpeechError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(speechState.message)));
        }
      },
      builder: (context, speechState) {
        final isListening =
            speechState is SpeechRecognizing ||
            speechState is SpeechReady && chatCubit.state.isListening;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(width: 0.5, color: Colors.white),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

          child: Row(
            children: [
              // 🎤 Mic Button
              !state.isSending && !state.isSpeaking
                  ? Material(
                      color: isListening
                          ? Colors.redAccent
                          : Theme.of(context).colorScheme.secondaryContainer,
                      shape: const CircleBorder(),
                      child: BlocBuilder<LanguageCubit, String>(
                        builder: (context, state) {
                          return InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              if (isListening) {
                                await speechCubit.stopListening();
                              } else {
                                try {
                                  await speechCubit.initialize();
                                  await speechCubit.startListening(
                                    languageCode: state,
                                  );
                                } catch (e) {
                                  log('Error starting listening: $e');
                                }
                              }
                              // chatCubit.toggleListening();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Icon(
                                isListening ? Icons.mic : Icons.mic_none,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () {
                        state.isSpeaking
                            ? chatCubit.stopSpeech()
                            : GenAI.stopGeneration();
                      },
                    ),
              const SizedBox(width: 8),

              // 💬 Text field
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,

                  onSubmitted: (value) {
                    _send(context);
                  },
                  decoration: InputDecoration(
                    hintText: isListening
                        ? 'Listening...'
                        : 'Type or speak your message...',
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Material(
                color: Theme.of(context).primaryColor,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _send(context),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
