// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';

class TextFile extends StatelessWidget {
  const TextFile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      child: Center(
          child: Text(
        'hello',
        style: TextStyle(fontSize: 20, color: Colors.cyan),
      )),
    );
  }
}
