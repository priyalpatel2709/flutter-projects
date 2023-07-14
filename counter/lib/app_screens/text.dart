// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';

class TextFile extends StatelessWidget {
  var name;
  TextFile(this.name);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 100,
      color: Colors.blue,
      child: Center(
          child: Container(
            
            child: Text(
                  'hi,$name',
                  style: TextStyle(fontSize: 50, color: const Color.fromARGB(255, 0, 0, 0)),
                )
          )
      ),
    );
  }
}
