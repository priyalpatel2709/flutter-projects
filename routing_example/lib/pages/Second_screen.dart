import 'package:flutter/material.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({ Key? key }) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
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
            const Text('I am 2nd page', style: TextStyle(fontSize: 21,color: Color.fromARGB(255, 35, 104, 138)),),
            ElevatedButton(onPressed: (){}, child: Text('Go To 3nd screen'))
          ],
        ),
      )
    );
  }
}