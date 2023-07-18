// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:dotoapp/uiti/dailog_box.dart';
import 'package:dotoapp/uiti/todolist.dart';
import 'package:flutter/material.dart';

import 'pages/listview.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DO TO APP',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List dotoList = [
    ['go to temple',true],
    ['go to office',false],
    ['go to gym',true],
    ['go to depo',false],
    ['go to slpeep',true],
  ];

  void checkboxclick(bool? value,int index){
    setState(() {
        dotoList[index][1] = !dotoList[index][1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 58, 55,0.89),
        elevation: 1.2,
        title: Center(
          child: Text('Do-To List',style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)))
        ),
      ),
      body: Container(
        color: Color.fromRGBO(237, 214, 172, 0.89),
        child: ListView.builder(
          itemCount: dotoList.length,
          itemBuilder: (context,index){
            return Todolist(taskName: dotoList[index][0], taskcomplated: dotoList[index][1], onChanged: (value)=>checkboxclick(value,index));
          })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (BuildContext context){
              return DailogBox();
            });
        },
       child: Icon(Icons.add),
       backgroundColor: const Color.fromRGBO(7, 190, 184,50)
       ) ,
    );
  }
}
