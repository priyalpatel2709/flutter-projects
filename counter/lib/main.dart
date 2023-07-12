import 'package:flutter/material.dart';
import 'app_screens/frist_screen.dart';
import 'app_screens/button_widget.dart';
import 'app_screens/text.dart';
import 'app_screens/images.dart';
import 'app_screens/row_col.dart';
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
        body: Row_col(),
      ),
    );
  }
}
