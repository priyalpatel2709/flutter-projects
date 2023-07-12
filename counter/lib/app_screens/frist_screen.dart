import 'dart:math';

import 'package:flutter/material.dart';

class FristScreen extends StatelessWidget {
  const FristScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      return Material(
        color : Color.fromARGB(255, 57, 160, 245),
        child : Center(
          child : Text(luckNumber(),
                  textDirection:TextDirection.ltr,
                  style: TextStyle(color: const Color.fromARGB(255, 73, 72, 72), fontSize: 40.0),
                  ),
        ),
      );
  }

  String luckNumber(){
    var random = Random();
    int luckNumber = random.nextInt(10);
    return 'your luck number is $luckNumber';
  }

}