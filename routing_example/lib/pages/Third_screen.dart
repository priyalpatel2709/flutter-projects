// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/routes_name.dart';

class ThirdScreen extends StatefulWidget {
  dynamic data;
  ThirdScreen({ Key? key, required this.data }) : super(key: key);

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title:  Text("Routing"),
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
              Text('Name:- ${widget.data['name']}',style: TextStyle(fontSize: 15.5,color: CupertinoColors.activeBlue) ,),
              Text('City:- ${widget.data['city']}',style: TextStyle(fontSize: 15.5,color: CupertinoColors.activeOrange)),
              ElevatedButton(onPressed: (){
                Navigator.pushNamed(context, RoutesName.NewScreen,  arguments: {
                  'name' : "ja be",
                  'work' : 'i am not working',
                }  );
              }, child: Icon(Icons.trending_neutral_sharp))
            ],)
          ],
        ),
      )
    );
  }
}