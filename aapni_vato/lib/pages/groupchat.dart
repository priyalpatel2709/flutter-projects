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
  final TextEditingController _grpNameController = TextEditingController();
  List<FetchUser> userList = [];
  List<FetchUser> addedUserList = [];
  bool isSearching = false;
  User? storedUser;
  UserInfo userInfo = UserInfo();
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
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
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white12,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _grpNameController,
                      decoration: InputDecoration(
                        labelText: 'Enter group name',
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
                              setState(() {
                                isTyping = value.isNotEmpty;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Search Name',
                              labelStyle: TextStyle(color: Colors.white70),
                              hintText: 'e.g., Maya',
                              hintStyle: TextStyle(color: Colors.white10),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isTyping ? Colors.white70 : Colors.white10,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              setState(() {
                                isSearching = true;
                                userList.clear();
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
                                      userList.add(FetchUser.fromJson(i));
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
                                      message: 'Enter a name...',
                                    );
                                  },
                                );
                              }
                            },
                            icon: Icon(Icons.search),
                            color: isTyping ? Colors.white70 : Colors.white10,
                          ),
                        ),
                      ],
                    ),
                    if (isSearching)
                      CircularProgressIndicator()
                    else if (userList.isNotEmpty)
                      SingleChildScrollView(
                        child: Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: userList.length,
                            itemBuilder: (context, index) {
                              var user = userList[index];
                              return InkWell(
                                onTap: () {
                                  if (addedUserList.contains(user)) {
                                    return;
                                  } else {
                                    setState(() {
                                      addedUserList.add(user);
                                    });
                                  }
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.pic.toString()),
                                  ),
                                  title: Text(
                                    user.name.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                        ),
                      ),
                  ],
                ),
              ),
              if (addedUserList.isNotEmpty)
                SingleChildScrollView(
                  child: Container(
                    height: 100, // Adjust the height as needed
                    child: Wrap(
                      spacing: 10.0, // Adjust spacing between names as needed
                      children: addedUserList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final addedUser = entry.value;
                        return Chip(
                          onDeleted: () {
                            setState(() {
                              addedUserList.removeAt(index);
                            });
                          },
                          deleteIcon: const Icon(
                            Icons.remove_circle,
                            color: Colors.black54,
                          ),
                          label: Text(addedUser.name.toString(),
                              style: TextStyle(color: Colors.white70)),
                          backgroundColor:
                              const Color.fromARGB(255, 77, 80, 85),
                        );
                      }).toList(),
                    ),
                  ),
                )
              else
                Center(
                  child: Text(
                    'No user Added',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
