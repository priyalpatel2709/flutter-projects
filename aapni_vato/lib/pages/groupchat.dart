// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class Groupchat extends StatefulWidget {
  const Groupchat({Key? key}) : super(key: key);

  @override
  _GroupchatState createState() => _GroupchatState();
}

class _GroupchatState extends State<Groupchat> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        title: Text('Create Group'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        // width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
                controller: _controller,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(color: Colors.white24, width: 2)),
                  labelText: 'Search Name',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: "e.g, Maya",
                  hintStyle: TextStyle(color: Colors.white10),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                )),
          ],
        ),
      ),
    );
  }
}
