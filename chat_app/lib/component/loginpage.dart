// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'chat_page.dart';

class Loginpage extends StatefulWidget {
const Loginpage({ Key? key }) : super(key: key);

  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

  void _login(BuildContext context) {
    String username = 'rafa';
    if (username.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Chat_page(userName: username)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loginpage'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('This is Loginpage content.'),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Button Text'),
            )
          ],
        ),
      ),
    );
  }
}