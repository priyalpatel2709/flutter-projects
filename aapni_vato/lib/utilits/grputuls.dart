import 'package:flutter/material.dart';

import '../model/mychat.dart';


Future<void> grpInfo(List<Chat> chats,context,name) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(name),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 10.0,
                  children: chats[0].users.map((user) {
                    Color color;
                    chats[0].groupAdmin?.id == user.id
                        ? color = Color.fromARGB(100, 0, 0, 0)
                        : color = Colors.white;

                    Color bgcolor;
                    chats[0].groupAdmin?.id == user.id
                        ? bgcolor = Color.fromARGB(255, 255, 255, 255)
                        : bgcolor = const Color.fromARGB(255, 77, 80, 85);
                    return Chip(
                      label: Text(
                        user.name,
                        style: TextStyle(color: color),
                      ),
                      backgroundColor: bgcolor,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }