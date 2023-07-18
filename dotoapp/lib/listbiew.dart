// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Listbiew extends StatefulWidget {
  const Listbiew({ Key? key }) : super(key: key);

  @override
  _ListbiewState createState() => _ListbiewState();
}

class _ListbiewState extends State<Listbiew> {
   bool valuefirst = false;  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(221, 97, 74,50),
      child: ListView.builder(
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                leading: Checkbox(
                  checkColor: const Color.fromARGB(255, 0, 0, 0),
                  activeColor: Color.fromRGBO(188, 214, 172,1),  
                  value: valuefirst,
                  onChanged: ( bool?  value) {
                    setState(() {
                      valuefirst = value!;
                    });
                  },
                ),
                trailing: const Text(
                  "GFG",
                  style: TextStyle(color: Color.fromARGB(255, 232, 235, 232), fontSize: 15),
                ),
                title: Text("List item $index",style:TextStyle(color: Color.fromRGBO(239, 214, 172, 1))),);
          }),
    );
  }
}