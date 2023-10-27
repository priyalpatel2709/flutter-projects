// ignore_for_file: prefer_const_constructors,

import 'package:flutter/material.dart';

class selectNumber extends StatelessWidget {
  const selectNumber({
    super.key,
    required TextEditingController startController,
    required TextEditingController endController,
  })  : _startController = startController,
        _endController = endController;

  final TextEditingController _startController;
  final TextEditingController _endController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          child: TextField(
            controller: _startController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Start',
              hintText: '12',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        Container(
          width: 100,
          child: TextField(
            controller: _endController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'End',
              hintText: '14',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
