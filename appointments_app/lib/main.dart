// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'pages/Admin-pages/adduserinfo.dart';
import 'pages/Admin-pages/getuser.dart';
import 'utilits/route.dart';
import 'utilits/routes_name.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 164, 183)),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.Addappointment,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text('appointments'),
      ),
    );
  }
}
