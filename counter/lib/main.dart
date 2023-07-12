import 'package:flutter/material.dart';
import 'app_screens/frist_screen.dart';
import 'app_screens/button_widget.dart';
import 'app_screens/text.dart';
import 'app_screens/images.dart';
import 'app_screens/row_col.dart';
import 'app_screens/scroll_view.dart';
import 'app_screens/list_view.dart';
import 'app_screens/listview_builder.dart';
import 'app_screens/them_demo.dart';
import 'dart:math';

void main() => runApp(MyFirstApp());

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My First App are you ?",
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter App"),
      ),
      body: ThemDemo(),
    );
  }
}
