// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class Splace_screen extends StatefulWidget {
const Splace_screen({ Key? key }) : super(key: key);

  @override
  _Splace_screenState createState() => _Splace_screenState();
}

class _Splace_screenState extends State<Splace_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Splace_screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text('This is Splace_screen content. bla bla lla'),
      ),
    );
  }
}