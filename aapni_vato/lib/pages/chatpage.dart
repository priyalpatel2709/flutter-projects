// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class Chatpage extends StatefulWidget {
const Chatpage({ Key? key }) : super(key: key);

  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatpage'),
      ),
      body: Center(
        child: Text('This is Chatpage content.'),
      ),
    );
  }
}