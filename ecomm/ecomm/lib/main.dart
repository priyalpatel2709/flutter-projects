// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:ecomm/pages/fristapi.dart';

import 'pages/login.dart';
import 'pages/photos.dart';
import 'pages/product_list.dart';
import 'pages/productwithimg.dart';
import 'pages/singup.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 27, 1, 1),
          title: Text('E-comm',style: TextStyle(color: Colors.white),),
        ),
        body: Singup(),
      ),
    );
  }
}