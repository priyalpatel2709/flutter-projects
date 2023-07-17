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
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromARGB(255, 57, 160, 245),
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
                backgroundColor: Colors.blue,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                var preferences = await SharedPreferences.getInstance();
                await preferences.clear();
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
    return '${widget.name}\'s luck number is $luckNumber';
  }
}
