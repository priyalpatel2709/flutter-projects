import 'package:flutter/material.dart';
import 'app_screens/frist_screen.dart';
import 'dart:math';

void main() => runApp(MyFirstApp());

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My First App",
      home: Scaffold(
        appBar: AppBar(
          title: Text("My First App"),
        ),
        body: Center(
          child: Container(
          width: 100,
          height: 100,
          color: Colors.blueGrey,
          child: Center(
            child: Text('hello dev.')
          ),
        )),
      ),
    );
  }
}
