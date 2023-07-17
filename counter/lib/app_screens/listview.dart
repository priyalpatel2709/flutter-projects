// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';


class Listview extends StatefulWidget {
  const Listview({ Key? key }) : super(key: key);

  @override
  _ListviewState createState() => _ListviewState();
}

class _ListviewState extends State<Listview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      color: Colors.red,
    );
  }
}