// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/database.dart';
import '../model/mychat.dart';
import '../route/routes_name.dart';
import 'package:http/http.dart' as http;

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

  Future<List<Chat>> fetchChatData() async {
    final url = Uri.parse('https://single-chat-app.onrender.com/api/chat');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${storedUser!.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<Chat> chats =
          jsonList.map((json) => Chat.fromJson(json)).toList();

      return chats; // Return the list of Chat objects parsed from the JSON response
    } else {
      // Handle the error if the request fails.
      print('Failed to load data: ${response.statusCode}');
      throw Exception('Failed to load data: ${response.statusCode}');
    }
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
              currentAccountPicture: storedUser!.imageUrl == null
                  ? null // If imageUrl is null, don't display currentAccountPicture
                  : GestureDetector(
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(storedUser!.imageUrl.toString()),
                      ),
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
      body: FutureBuilder<List<Chat>>(
        future: fetchChatData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No chat data available.');
          } else {
            // Data has been successfully fetched
            final chats = snapshot.data!;

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final chatUser = storedUser!.userId == chat.users.first.id
                    ? chat.users.last
                    : chat.users.first;

                final chatId = chat.id;
                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.Chatmessage_page,
                        arguments: {
                          "chatId": chatId,
                          "name": chatUser.name,
                          "dp": chatUser.pic
                        });
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundImage: NetworkImage(chatUser.pic)),
                    title: Text(chatUser.name), // Access user name
                  ),
                );
              },
            );
          }
        },
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
    Navigator.pushNamed(context, RoutesName.AddFriend);
  }
}
