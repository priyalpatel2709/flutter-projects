// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../data/database.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({Key? key}) : super(key: key);

  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  UserInfo userInfo = UserInfo();
  User? storedUser; // Declare a User object to hold the retrieved user information

  @override
  void initState() {
    super.initState();
    
    // Retrieve the stored user information when the Chatpage is initialized
    storedUser = userInfo.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatpage'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (storedUser != null) {
              // Print the stored user information
              print('UserID: ${storedUser!.userId}');
              print('Token: ${storedUser!.token}');
              print('Name: ${storedUser!.name}');
              print('Email: ${storedUser!.email}');
              print('ImageUrl: ${storedUser!.imageUrl ?? 'No Image'}'); // Handle null imageUrl
            } else {
              print('User information not found in Hive.');
            }
          },
          child: Text('Print Stored Values'),
        ),
      ),
    );
  }
}

