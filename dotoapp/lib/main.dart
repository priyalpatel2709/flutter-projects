// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

import 'listbiew.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 58, 55,1),
        elevation: 1.2,
        title: Center(
          child: Text('Do-To List',style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)))
        ),
      ),
      body: Listbiew(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (BuildContext context){
              return AlertDialog(
                backgroundColor: Color.fromRGBO(239, 214, 172, 1),
                scrollable: true,
                title: Text('Thing\'s to do'),
                content: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Form(child: 
                  Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                        labelText: "Task",
                        icon: Icon(Icons.task),
                      )
                      ),
                      SizedBox(height: 11,),
                      TextButton(onPressed: (){}, child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Icon(Icons.add,color: Color.fromRGBO(7, 190, 184,50)),
                          Text("Add",style: TextStyle(color: Color.fromRGBO(7, 190, 184,50)),)
                        ] 
                      )  )
                    ],
                  )
                  ),
                ),
              );
            });
        },
       child: Icon(Icons.add),
       backgroundColor: const Color.fromRGBO(7, 190, 184,50)
       ) ,
    );
  }
}
