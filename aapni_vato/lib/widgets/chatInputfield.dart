// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isImg;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onSendPressed;

  ChatInputField({
    required this.controller,
    required this.isImg,
    required this.onAttachmentPressed,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
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
          SizedBox(width: 3.0),
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
            icon: Icon(Icons.attach_file),
          ),
          IconButton(
            onPressed: onSendPressed,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
