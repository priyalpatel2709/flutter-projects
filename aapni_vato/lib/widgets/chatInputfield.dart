import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isImg;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onSendPressed;

  const ChatInputField({super.key, 
    required this.controller,
    required this.isImg,
    required this.onAttachmentPressed,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 5 ),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40.0),
          bottomRight: Radius.circular(40.0),
          topLeft: Radius.circular(40.0),
          bottomLeft: Radius.circular(40.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(width: 3.0),
          Expanded(
            child: TextField(
              enabled: !isImg,
              controller: controller,
              decoration: InputDecoration(
                hintText: 'message...',
                enabled: !isImg,
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onAttachmentPressed,
            icon: const Icon(Icons.attach_file),
          ),
          IconButton(
            onPressed: onSendPressed,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
