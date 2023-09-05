// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../data/database.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({Key? key}) : super(key: key);

  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  UserInfo userinfo = UserInfo();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatpage'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print(userinfo.user_info);
          },
          child: Text('Button Text'),
        ),
      ),
    );
  }
}
