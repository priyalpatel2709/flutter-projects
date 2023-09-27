import 'package:flutter/material.dart';

import '../model/mychat.dart';

Future<void> grpInfo(List chats, context, name) {
  List<Chat> typedChats = chats.cast<Chat>();
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
                children: typedChats[0].users.map((user) {
                  Color color;
                  Color bgcolor;
                  bool isAdmin;
                  typedChats[0].groupAdmin?.id == user.id
                      ? isAdmin = true
                      : isAdmin = false;
                  if (isAdmin) {
                    color = const Color.fromARGB(255, 0, 0, 0);
                    bgcolor = const Color.fromARGB(255, 255, 255, 255);
                  } else {
                    color = Colors.white;
                    bgcolor = const Color.fromARGB(255, 77, 80, 85);
                  }

                  return Chip(
                    avatar: !isAdmin
                        ? const SizedBox()
                        : const CircleAvatar(
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              // size: 20,
                            ),
                          ),
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
