import 'package:counter/app_screens/new_page.dart';
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
import 'app_screens/input_field.dart';
import 'app_screens/date_time.dart';
import 'app_screens/date_time_piker.dart';
import 'app_screens/grid_widset.dart';
import './widget/rounded_btn.dart';
import './ui_helper/utli.dart';
import 'app_screens/calutator.dart';

void main() => runApp(MyFirstApp());

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My First App are you ?",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter App"),
      ),
      body: NewPage(),
    );
  }
}
