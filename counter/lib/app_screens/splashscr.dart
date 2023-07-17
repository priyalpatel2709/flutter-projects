// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_screens/frist_screen.dart';
import '../ui_helper/utli.dart';

import 'package:flutter/material.dart';
import '../main.dart';

class Splashscr extends StatefulWidget {
  const Splashscr({super.key});

  @override
  State<Splashscr> createState() => _SplashscrState();
}

class _SplashscrState extends State<Splashscr> {
  @override
  void initState() {
    super.initState();
    wharetogo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
          child: CircleAvatar(
        backgroundColor: Color(0xffE6E6E6),
        radius: 30,
        child: Icon(Icons.home),
      )),
    );
  }

  void wharetogo() async {
    var pref = await SharedPreferences.getInstance();
    var isloging = pref.getBool('islogin');
    var name = pref.getString('userName');
    print('$isloging');

    Timer(Duration(seconds: 1), () {
      if (isloging != null) {
        if (isloging) {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> FristScreen(name:name)) );
        } else {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> HomePage()) );
        }
      } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage();
      }));
      }


    });
  }
}
