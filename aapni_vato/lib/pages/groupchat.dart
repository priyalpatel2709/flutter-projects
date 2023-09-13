// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/database.dart';
import '../model/alluserData.dart';
import '../utilits/errordialog.dart';
import 'package:http/http.dart' as http;

class Groupchat extends StatefulWidget {
  const Groupchat({Key? key}) : super(key: key);

  @override
  _GroupchatState createState() => _GroupchatState();
}

class _GroupchatState extends State<Groupchat> {
  UserInfo userInfo = UserInfo();
  User? storedUser;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  String name = '';

  List<FetchUser> userlist = [];
  bool isSearching = false;
  @override
  void initState() {
    storedUser = userInfo.getUserInfo();
    super.initState();
  }

  void dispose() {
    // Dispose of the debounce timer when the widget is disposed.
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        title: Text('Create Group'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide:
                              BorderSide(color: Colors.white, width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide:
                              BorderSide(color: Colors.white24, width: 2)),
                      labelText: 'Search Name',
                      labelStyle: TextStyle(color: Colors.white),
                      hintText: "e.g, Maya",
                      hintStyle: TextStyle(color: Colors.white10),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24)),
                    )),
                Text('Star Rating'),
              ],
            ),
            // TextField(
            //     controller: _controller,
            //     decoration: InputDecoration(
            //       focusedBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(11),
            //           borderSide: BorderSide(color: Colors.white, width: 2)),
            //       enabledBorder: OutlineInputBorder(
            //           borderRadius: BorderRadius.circular(11),
            //           borderSide:
            //               BorderSide(color: Colors.white24, width: 2)),
            //       labelText: 'Search Name',
            //       labelStyle: TextStyle(color: Colors.white),
            //       hintText: "e.g, Maya",
            //       hintStyle: TextStyle(color: Colors.white10),
            //       prefixIcon: Icon(Icons.search),
            //       border: OutlineInputBorder(
            //           borderSide: BorderSide(color: Colors.white24)),
            //     )),
            // IconButton(
            //     onPressed: () async {
            //       try {
            //         final response = await http.get(
            //           Uri.parse(
            //               'https://single-chat-app.onrender.com/api/user?search=${_controller.text.toString()}'),
            //           headers: {
            //             'Authorization': 'Bearer ${storedUser!.token}',
            //             'Content-Type': 'application/json'
            //           },
            //         );
            //         var data = jsonDecode(response.body.toString());

            //         if (response.statusCode == 200) {
            //           for (var i in data) {
            //             userlist.add(FetchUser.fromJson(i));
            //           }

            //           setState(() {
            //             isSearching = false;
            //           });
            //         } else {
            //           showDialog(
            //             context: context,
            //             builder: (BuildContext context) {
            //               return ErrorDialog(
            //                 title: 'Fail',
            //                 message: 'Error: ${response.statusCode}',
            //               );
            //             },
            //           );
            //         }
            //       } catch (e) {
            //         showDialog(
            //           context: context,
            //           builder: (BuildContext context) {
            //             return ErrorDialog(
            //               title: 'Fail',
            //               message: 'Error: $e',
            //             );
            //           },
            //         );
            //       }
            //     },
            //     icon: Icon(Icons.search))

            // ElevatedButton(
            //   onPressed: () async {
            //     try {
            //       final response = await http.get(
            //         Uri.parse(
            //             'https://single-chat-app.onrender.com/api/user?search=${_controller.text.toString()}'),
            //         headers: {
            //           'Authorization': 'Bearer ${storedUser!.token}',
            //           'Content-Type': 'application/json'
            //         },
            //       );
            //       var data = jsonDecode(response.body.toString());

            //       if (response.statusCode == 200) {
            //         for (var i in data) {
            //           userlist.add(FetchUser.fromJson(i));
            //         }

            //         setState(() {
            //           isSearching = false;
            //         });
            //       } else {
            //         showDialog(
            //           context: context,
            //           builder: (BuildContext context) {
            //             return ErrorDialog(
            //               title: 'Fail',
            //               message: 'Error: ${response.statusCode}',
            //             );
            //           },
            //         );
            //       }
            //     } catch (e) {
            //       showDialog(
            //         context: context,
            //         builder: (BuildContext context) {
            //           return ErrorDialog(
            //             title: 'Fail',
            //             message: 'Error: $e',
            //           );
            //         },
            //       );
            //     }
            //   },
            //   child: Text('Button Text'),
            // ),
            if (isSearching)
              CircularProgressIndicator() // Show loading indicator while searching
            else if (userlist.isNotEmpty)
              SingleChildScrollView(
                child: Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: userlist.length,
                    itemBuilder: (context, index) {
                      var user = userlist[index];
                      print(' ${'Line 138:'} $user');
                      return ListTile(
                        // title: Text(user['name'].toString()),
                        title: Text(
                          'fff',
                          style: TextStyle(color: Colors.white38),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Text('No results found'),
          ],
        ),
      ),
    );
  }
}
