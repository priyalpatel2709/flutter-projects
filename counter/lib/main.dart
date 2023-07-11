import 'package:flutter/material.dart';

void main() =>runApp(MyFristApp() );
  
  

class MyFristApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  MaterialApp(
      title: "my frist app",
      home: Material(
        color: const Color.fromARGB(255, 92, 174, 241),
        child: Center(
          child: Text(
            "hello from priyal",
            textDirection: TextDirection.ltr,
            style: TextStyle(color: Colors.white,fontSize: 40.0),
          ),
        ),
      ),
    );
    
  }


}
