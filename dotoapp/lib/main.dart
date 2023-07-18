// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';


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
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 253, 253, 253)),
        useMaterial3: true,
      ),
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
        
        backgroundColor: const Color.fromRGBO(18, 41, 50,100),
        elevation: 1.2,
        title: Text('Do-To List'),
      ),
      body: Container(
        color: Color.fromRGBO(44, 81, 76, 100),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Do To App',
              ),
              ],
          ),
        )
      ),
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
                          Icon(Icons.add,color: Color.fromRGBO(255, 102, 102,100)),
                          Text("Add",style: TextStyle(color: Color.fromRGBO(255, 102, 102,100)),)
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
       backgroundColor: const Color.fromRGBO(255, 102, 102,100)
       ) ,
    );
  }
}
