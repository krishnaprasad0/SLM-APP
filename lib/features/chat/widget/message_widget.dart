import 'package:flutter/material.dart';
import 'package:slm_poc/features/chat/model/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final radius = Radius.circular(14);
    final textColor = Colors.white;
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final alignRow = isMine ? MainAxisAlignment.end : MainAxisAlignment.start;
    final time = TimeOfDay.fromDateTime(message.timestamp).format(context);

    return Row(
      mainAxisAlignment: alignRow,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: radius,
                    topRight: radius,
                    bottomLeft: isMine ? radius : const Radius.circular(4),
                    bottomRight: isMine ? const Radius.circular(4) : radius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: EdgeInsets.only(
                  left: isMine ? 0 : 6,
                  right: isMine ? 6 : 0,
                ),
                child: Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
