// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/database.dart';
import '../route/routes_name.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({Key? key}) : super(key: key);

  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final _mybox = Hive.box('user_info');
  UserInfo userInfo = UserInfo();
  User?
      storedUser; 

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
  }

  Future<void> clearHiveStorage() async {
    await _mybox.deleteFromDisk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatpage'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                if (storedUser != null) {
                  // Print the stored user information
                  print('UserID: ${storedUser!.userId}');
                  print('Token: ${storedUser!.token}');
                  print('Name: ${storedUser!.name}');
                  print('Email: ${storedUser!.email}');
                  print(
                      'ImageUrl: ${storedUser!.imageUrl ?? 'No Image'}'); // Handle null imageUrl
                } else {
                  print('User information not found in Hive.');
                }
              },
              child: Text('Print Stored Values'),
            ),
            ElevatedButton(
              onPressed: () {
                // clearHiveStorage();
                Navigator.pushReplacementNamed(context, RoutesName.Login);
              },
              child: Text('Log Out'),
            )
          ],
        ),
      ),
    );
  }
}
