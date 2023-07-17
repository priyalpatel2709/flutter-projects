// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class listView extends StatelessWidget {
  const listView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(padding: EdgeInsets.all(10), child: Text('1')),
          Padding(padding: EdgeInsets.all(10), child: Text('2')),
          Padding(padding: EdgeInsets.all(10), child: Text('3')),
          Padding(padding: EdgeInsets.all(10), child: Text('4')),
          Padding(padding: EdgeInsets.all(10), child: Text('5')),
          Padding(padding: EdgeInsets.all(10), child: Text('6')),
          Padding(padding: EdgeInsets.all(10), child: Text('7')),
          Padding(padding: EdgeInsets.all(10), child: Text('8')),
          Padding(padding: EdgeInsets.all(10), child: Text('9')),
          Padding(padding: EdgeInsets.all(10), child: Text('10')),
          Padding(padding: EdgeInsets.all(10), child: Text('11')),
          Padding(padding: EdgeInsets.all(10), child: Text('12')),
          Padding(padding: EdgeInsets.all(10), child: Text('13')),
          Padding(padding: EdgeInsets.all(10), child: Text('14')),
          Padding(padding: EdgeInsets.all(10), child: Text('15')),
          Padding(padding: EdgeInsets.all(10), child: Text('16')),
          Padding(padding: EdgeInsets.all(10), child: Text('17')),
          Padding(padding: EdgeInsets.all(10), child: Text('18')),
          Padding(padding: EdgeInsets.all(10), child: Text('19')),
          Padding(padding: EdgeInsets.all(10), child: Text('20')),
        ],
      ),
    );
  }
}
