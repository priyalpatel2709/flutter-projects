// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({ Key? key }) : super(key: key);

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text("Routing")),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'I am 3nd page',style: TextStyle(fontSize: 21,color: Color.fromARGB(255, 35, 104, 138) ),
            ),
            SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              Text('data form 2nd',style: TextStyle(fontSize: 15.5,color: CupertinoColors.activeBlue) ,),
              Text('more data form 2nd',style: TextStyle(fontSize: 15.5,color: CupertinoColors.activeOrange)),
            ],)
          ],
        ),
      )
    );
  }
}