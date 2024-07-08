import 'package:chatapp/models/chat.dart';
import 'package:flutter/material.dart';


class Chat extends StatelessWidget {
  
  final ChatModel chat;
  const Chat({
    super.key, 
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        chat.isUser ? const Spacer() : Container(),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 16, bottom: 16),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.6
          ),
          decoration: BoxDecoration(
            color: chat.isUser ? const Color(0xFF102A49): const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(chat.text, style: TextStyle(color: chat.isUser ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w600))
        ),
        !chat.isUser ? const Spacer() : Container(),
      ]
    );
  }
}
