// ignore_for_file: prefer_const_constructors,

import 'package:flutter/material.dart';

import '../route/routes_name.dart';

class MessagepageAppbar extends StatelessWidget {
  final bool isGrpChat;
  final String userProfile;
  final String userName;
  final String status;
  final VoidCallback grpInfo;
  final String chatId;
  const MessagepageAppbar(
      {Key? key,
      required this.isGrpChat,
      required this.userProfile,
      required this.userName,
      required this.status,
      // required Future<void> grpInfo,
      required this.grpInfo, 
      required this.chatId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacementNamed(context,
              RoutesName.Chatpage); // Navigate back to the previous page
        },
      ),
      actions: [
        isGrpChat
            ? IconButton(onPressed: grpInfo, icon: const Icon(Icons.info))
            : const SizedBox()
      ],
      title: Row(
        children: [
          Hero(
            tag: chatId,
            placeholderBuilder: (context, size, widget) {
              return CircularProgressIndicator(); // Show a loading indicator
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(userProfile),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                status,
                style: const TextStyle(fontSize: 15),
              )
            ],
          ),
        ],
      ),
    );
  }
}
