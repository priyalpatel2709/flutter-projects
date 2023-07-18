// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class DailogBox extends StatefulWidget {
  final controller;
  VoidCallback addTolist;
  DailogBox({Key? key,required this.controller,required this.addTolist});

  @override
  _DailogBoxState createState() => _DailogBoxState();
}

class _DailogBoxState extends State<DailogBox> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromRGBO(239, 214, 172, 0.89),
      scrollable: true,
      title: Text('Thing\'s to do'),
      content: Padding(
        padding: EdgeInsets.all(8.0),
        child: Form(
            child: Column(
          children: [
            TextFormField(
              controller: widget.controller , 
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black
                  ),
                  ),
                focusedBorder:OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black
                  )
                ),
                labelText: "Task",
                labelStyle: TextStyle(
                  color: Colors.black
                ),
              icon: Icon(Icons.task,color: Colors.black,),
              )),
            SizedBox(
              height: 11,
            ),
            TextButton(
                onPressed: () {
                  widget.addTolist();
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add, color: Color.fromRGBO(0, 0, 0, 0.808)),
                  Text(
                    "Add",
                    style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.808)),
                  )
                ]))
          ],
        )),
      ),
    );
  }
}
