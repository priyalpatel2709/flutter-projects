import 'dart:math';

import 'package:flutter/material.dart';

class FristScreen extends StatelessWidget {
  const FristScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
      return Material(
        color : Color.fromARGB(255, 57, 160, 245),
        child : Center(
          child : Card(
            shadowColor: Color.fromARGB(255, 196, 220, 248),
            elevation: 5,
            child: Text(luckNumber(),
                    textDirection:TextDirection.ltr,
                    style: TextStyle(color: const Color.fromARGB(255, 73, 72, 72), fontSize: 25.0,fontFamily: 'Demo',backgroundColor: Colors.blue),
                    )
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