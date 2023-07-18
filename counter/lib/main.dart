// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables

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
import 'app_screens/splashscr.dart';
import 'animation/tween.dart';
import 'animation/animate.dart';
import 'Shared_Pref/shared_pref.dart';
import 'app_screens/listview.dart';

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
      home: Splashscr(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        elevation: 20,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("Priyal Pate;"),
              accountEmail: Text("demo@test.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/img/images.jpg'),
                backgroundColor: Colors.red,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
              ),
              title: const Text('Page 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.train,
              ),
              title: const Text('Page 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Flutter App"),
        elevation: 20,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shopping_bag_outlined),
            tooltip: 'info',
          ),
        ],
      ),
      body: SharedPref(),
      floatingActionButton: FloatingActionButton(
        //Floating action button on Scaffold
        onPressed: () {
          //code to execute on button press
        },
        child: Icon(Icons.send), //icon inside button
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floating action button position to center

      bottomNavigationBar: BottomAppBar(
        //bottom navigation bar on scaffold
        color: Colors.blue,
        shape: CircularNotchedRectangle(), //shape of notch
        notchMargin:
            5, //notche margin between floating button and bottom appbar
        child: Row(
          //children inside bottom appbar
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.print,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.people,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
