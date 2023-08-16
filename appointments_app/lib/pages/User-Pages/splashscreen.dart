// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import 'addappointment.dart';
import 'login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({ Key? key }) : super(key: key);

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  var _mybox = Hive.box('user');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wharetogo();
  }

  void wharetogo() async {
    Future.delayed(Duration(seconds: 2),(){
      if (_mybox.get("USER") == null || _mybox.get("USER") == []) {  
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> Login()) );
      }else{
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> Addappointment()) );
      }
    });

  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: CircleAvatar(
        backgroundColor: Color(0xffE6E6E6),
        radius: 30,
        child: Icon(Icons.home),
      )
      ),
    );
  }
  

}