import 'package:flutter/material.dart';

class datetime extends StatefulWidget {
  const datetime({super.key});

  @override
  State<datetime> createState() => _datetimeState();
}

class _datetimeState extends State<datetime> {
  // var time = DateTime.now();
  @override
  Widget build(BuildContext context) {
    var time = DateTime.now();
    return Container(
      width: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Text('i am ? ${time.hour}'),
        ElevatedButton(onPressed: (){
          // print(time);
          setState(() {
            
          });
        }, child: Text('get time'))
      ]),
    );
  }
}
