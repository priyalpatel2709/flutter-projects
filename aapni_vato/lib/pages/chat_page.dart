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
  final TextEditingController _controller = TextEditingController();
  final _mybox = Hive.box('user_info');
  UserInfo userInfo = UserInfo();
  User? storedUser;
  var loading = false;

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
  }

  List<FetchUser> userlist = [];

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
      body: loading
          ? Text('Loading')
          : userlist.isNotEmpty
              ? ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: userlist.length,
                  itemBuilder: (context, index) {
                    final user = userlist[index]; // Get the user data
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.pic.toString())),
                      title: Text(user.name.toString()),
                    );
                  },
                )
              : Center(
                  child: Text('No stored data available.'),
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
          content: loading
              ? Text('Loading')
              : TextField(
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
                userlist.clear();
                loading = true;
                setState(() {});
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
        loading = false;
        setState(() {});
        final jsonData = jsonDecode(response.body);

        if (jsonData is List) {
          for (var i in jsonData) {
            userlist.add(FetchUser.fromJson(i));
          }
          setState(() {});
          _controller.clear();
          Navigator.of(context).pop();
        } else {
          // Handle error if jsonData is not a List
        }
      } else {
        // Handle error if needed
      }
    } catch (e) {
      loading = false;
      setState(() {});
      print('Error: $e');
    }
  }
}
