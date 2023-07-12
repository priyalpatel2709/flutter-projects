import 'package:flutter/material.dart';

void main() => runApp(MyFirstApp());

class MyFirstApp extends StatelessWidget {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My First App",
      home: Scaffold(
        appBar: AppBar(
          title: Text("My First App"),
        ),
        body: Material(
          color: Color.fromARGB(255, 92, 174, 241),
          child: Center(
            child: Text(
              "Hello from Priyal",
              textDirection: TextDirection.ltr,
              style: TextStyle(color: Colors.white, fontSize: 40.0),
            ),
          ),
        ),
      ),
    );
  }
}
