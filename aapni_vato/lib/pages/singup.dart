// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class Singup extends StatefulWidget {
const Singup({ Key? key }) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Singup'),
      ),
      body: Center(
        child: Text('This is Singup content.'),
      ),
    );
  }
}