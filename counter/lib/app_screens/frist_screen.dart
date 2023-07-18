// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, use_key_in_widget_constructors, must_be_immutable

import 'dart:math';
import '../Shared_Pref/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FristScreen extends StatefulWidget {
  var  name;

  FristScreen({required this.name});

  @override
  _FristScreenState createState() => _FristScreenState();
}

class _FristScreenState extends State<FristScreen> {
  var num =0;
  var bgcolor = [
    Colors.red,
    const Color.fromARGB(255, 92, 244, 54),
    Color.fromARGB(255, 244, 193, 54),
    Color.fromARGB(255, 15, 245, 103),
    Color.fromARGB(255, 0, 248, 248),
    const Color.fromARGB(255, 54, 174, 244),
    Color.fromARGB(255, 18, 62, 255),
    const Color.fromARGB(255, 136, 54, 244),
    const Color.fromARGB(255, 244, 54, 187),
    const Color.fromARGB(255, 244, 54, 165),
  ];
  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgcolor[num],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              luckNumber(),
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: const Color.fromARGB(255, 73, 72, 72),
                fontSize: 25.0,
                fontFamily: 'Demo',
                backgroundColor: bgcolor[num],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var preferences = await SharedPreferences.getInstance();
                await preferences.clear();
                Navigator.pop(context,MaterialPageRoute(builder: (context) => SharedPref(),));
                setState(() {
                });
              },
              child: Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  String luckNumber() {
    var random = Random();
    int luckNumber = random.nextInt(10);
    num=luckNumber;
    return '${widget.name}\'s luck number is $luckNumber';
  }
}
