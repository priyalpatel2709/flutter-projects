// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../utils/routes_name.dart';

class SecondScreen extends StatefulWidget {
  dynamic data;
  SecondScreen({ Key? key,required this.data }) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.data['node'])),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('I am 2nd page', style: TextStyle(fontSize: 21,color: Color.fromARGB(255, 35, 104, 138)),),
            ElevatedButton(onPressed: (){
              Navigator.pushNamed(context, RoutesName.ThirdScreen, arguments:{
                'name' : 'Priyal Patel',
                'city' : 'Vadodra',
                
              });
            }, child: Text('Go To 3nd screen'))
          ],
        ),
      )
    );
  }
}