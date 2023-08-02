// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

import '../utils/routes_name.dart';

class NewScreen extends StatefulWidget {
  dynamic data;
  NewScreen({ Key? key, required this.data }) : super(key: key);

  @override
  _NewScreenState createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text("Routing"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.data['name'],style: TextStyle(fontSize: 50),),
              Text(widget.data['work'],style: TextStyle(fontSize: 50),),
              ElevatedButton(onPressed: (){
                Navigator.pushNamed(context, RoutesName.MyHomePage);
              }, child: Text('Back To 1st'))
            ],
          ),
        ),
      ),
    );
  }
}