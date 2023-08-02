import 'package:flutter/material.dart';

import '../utils/routes_name.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({ Key? key }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Routing"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'I am home page',style: TextStyle(fontSize: 21,color: Color.fromARGB(255, 35, 104, 138))
            ),
            ElevatedButton(onPressed: (){
              Navigator.pushNamed(context, RoutesName.SecondScreen, arguments: {
                "node" : "amya"
              });
            }, child: Text('Go To 2nd screen'))
          ],
        ),
      )
    );
  }
}