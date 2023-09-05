// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/alluserData.dart';
import '../route/routes_name.dart';
import '../utilits/errordialog.dart';

class Chatpage extends StatefulWidget {
  const Chatpage({Key? key}) : super(key: key);

  @override
  _ChatpageState createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  final TextEditingController _controller = TextEditingController();
  final _mybox = Hive.box('user_info');
  UserInfo userInfo = UserInfo();
  User? storedUser;

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
  }

  Future<void> clearHiveStorage() async {
    await _mybox.deleteFromDisk();
  }

  List<FetchUser> userlist = [];

  @override
  Widget build(BuildContext context) {
    // print(userlist[0].name);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatpage'),
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
              title: const Text('Search Frind'),
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
                })
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text('data')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          adduser();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void adduser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search by Name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Name...',
              hintText: 'e.g., Harry...',
            ),
          ),
          actions: [
            TextButton(
              child: Text('Go'),
              onPressed: () {
                // Clear the previous search results
                userlist.clear();
                fetchUser(_controller.text.toString());
              },
            )
          ],
        );
      },
    );
  }

  Future<void> fetchUser(String name) async {
    try {
      final url = Uri.parse(
          'https://single-chat-app.onrender.com/api/user?search=$name');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${storedUser!.token}'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        for (var i in jsonData) {
          userlist.add(FetchUser.fromJson(i));
        }
        // Trigger a rebuild to display the search results
        setState(() {});
      } else {
        // Handle error if needed
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
