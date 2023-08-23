// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'chat_page.dart';

class Loginpage extends StatefulWidget {
const Loginpage({ Key? key }) : super(key: key);

  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
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
              onPressed: () {
                // Add your button press logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Chat_page(userName: 'John shah',)),
                );
              },
              child: Text('Button Text'),
            )
          ],
        ),
      ),
    );
  }
}