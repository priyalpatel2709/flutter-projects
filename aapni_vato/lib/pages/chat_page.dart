// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/alluserData.dart';
import '../route/routes_name.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({Key? key}) : super(key: key);

  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final _mybox = Hive.box('user_info');
  UserInfo userInfo = UserInfo();
  User? storedUser;
  var loading = false;

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
        title: Text('Appni Vato'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: Drawer(
        elevation: 20,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: GestureDetector(
                child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(storedUser!.imageUrl.toString())),
              ),
              accountName: Text(storedUser!.name),
              accountEmail: Text(storedUser!.email),
            ),
            ListTile(
              leading: Icon(
                Icons.search,
              ),
              title: const Text('Search Friend'),
              onTap: () {
                adduser();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // userinfo.clearUserData();
                Navigator.pushReplacementNamed(context, RoutesName.Login);
              },
            ),
          ],
        ),
      ),
      body: Text('my chats'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          adduser();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void adduser() {
    Navigator.pushNamed(context, RoutesName.AddFriend);
  }
}
