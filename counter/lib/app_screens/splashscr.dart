import 'dart:async';
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
    Timer(Duration(seconds: 5), () {
        Navigator.pushReplacement(context,
         MaterialPageRoute(builder: (context){
          return HomePage();

         })
         );
     });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Text('i am splash screen :)',style: myTextStyle1(),)
      ),
    );
  }
}