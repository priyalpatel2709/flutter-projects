// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../model/alluserData.dart';
import '../utilits/errordialog.dart';

class Groupchat extends StatefulWidget {
  const Groupchat({Key? key}) : super(key: key);

  @override
  _GroupchatState createState() => _GroupchatState();
}

class _GroupchatState extends State<Groupchat> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _grpNamecontroller = TextEditingController();
  List<FetchUser> userlist = [];
  bool isSearching = false;
  User? storedUser;
  UserInfo userInfo = UserInfo();
  bool isTypeing = false;

  @override
  void initState() {
    // TODO: implement initState
    storedUser = userInfo.getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        title: Text('Create Group'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: EdgeInsetsDirectional.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white12),
                child: Column(
                  children: [
                    
                    
                    TextField(
                      controller: _grpNamecontroller,
                      decoration: InputDecoration(
                              labelText: 'Enter group-Name.',
                              labelStyle: TextStyle(color: Colors.white70),
                            ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  isTypeing = false;
                                });
                              } else {
                                setState(() {
                                  isTypeing = true;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Search Name',
                              labelStyle: TextStyle(color: Colors.white70),
                              hintText: "e.g, Maya",
                              hintStyle: TextStyle(color: Colors.white10),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isTypeing ? Colors.white70 : Colors.white10),
                          child: IconButton(
                              onPressed: () async {
                                setState(() {
                                  isSearching = true;
                                  userlist.clear();
                                });
                                if (_controller.text.isNotEmpty) {
                                  try {
                                    final response = await http.get(
                                      Uri.parse(
                                          'https://single-chat-app.onrender.com/api/user?search=${_controller.text.toString()}'),
                                      headers: {
                                        'Authorization':
                                            'Bearer ${storedUser!.token}',
                                        'Content-Type': 'application/json'
                                      },
                                    );
                                    var data =
                                        jsonDecode(response.body.toString());

                                    if (response.statusCode == 200) {
                                      for (var i in data) {
                                        userlist.add(FetchUser.fromJson(i));
                                      }

                                      setState(() {
                                        isSearching = false;
                                      });
                                    } else {
                                      setState(() {
                                        isSearching = false;
                                      });
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ErrorDialog(
                                            title: 'Fail',
                                            message:
                                                'Error: ${response.statusCode}',
                                          );
                                        },
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      isSearching = false;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ErrorDialog(
                                          title: 'Fail',
                                          message: 'Error: $e',
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  setState(() {
                                    isSearching = false;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ErrorDialog(
                                        title: 'Fail',
                                        message: 'Enter name...',
                                      );
                                    },
                                  );
                                }
                              },
                              icon: Icon(Icons.search),
                              color:
                                  isTypeing ? Colors.white70 : Colors.white10),
                        ),
                      ],
                    ),
                    if (isSearching)
                      CircularProgressIndicator()
                    else if (userlist.isNotEmpty)
                      SingleChildScrollView(
                        child: Container(
                          height: 300,
                          child: ListView.builder(
                            itemCount: userlist.length,
                            itemBuilder: (context, index) {
                              var user = userlist[index];
                              return ListTile(
                                leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.pic.toString())),
                                title: Text(
                                  user.name.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Center(
                          child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.white70),
                      )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
