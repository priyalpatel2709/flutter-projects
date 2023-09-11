// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/alluserData.dart';
import '../route/routes_name.dart';
import '../utilits/errordialog.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({Key? key}) : super(key: key);

  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final TextEditingController _controller = TextEditingController();
  bool loading = false; // Changed var to bool
  User? storedUser;
  UserInfo userInfo = UserInfo();
  List<FetchUser> userlist = [];

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    print(userlist.length);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        title: Text('Appni Vato'),
         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  labelText: 'search by name or email..',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'e.g, maya',
                  hintStyle: TextStyle(color: Colors.white10),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              if (loading) // Show CircularProgressIndicator while loading
                Center(child: CircularProgressIndicator()),
              if (userlist.isNotEmpty)
                SizedBox(
                  height: 8.0,
                ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: userlist.length,
                  itemBuilder: (context, index) {
                    final user = userlist[index]; // Get the user data
                    return InkWell(
                      onTap: () {
                        // print(user.sId);
                        accessChat(user.sId);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.pic.toString())),
                        title: Text(user.name.toString()),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              ElevatedButton(
                onPressed: () {
                  loading = true;
                  setState(() {});
                  fetchUser(_controller.text.toString());
                },
                child: Text('Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchUser(String name) async {
    try {
      if(name == ''){
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

        for (var i in jsonData) {
          userlist.add(FetchUser.fromJson(i));
        }
        setState(() {});
        _controller.clear();
      } else {
        loading = false;
        setState(() {});
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: 'Fail',
              message: 'some this went wrong ${response.body}',
            );
          },
        );
      }
      }else{
        loading = false;
      setState(() {});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'Enter name or email..',
          );
        },
      );
      }

    } catch (e) {
      loading = false;
      setState(() {});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'Error $e',
          );
        },
      );
    }
  }

  void accessChat(String? sId) async {
    print(sId);
    try {
      final response = await http.post(
          Uri.parse('https://single-chat-app.onrender.com/api/chat'),
          headers: {
            'Authorization': 'Bearer ${storedUser!.token}',
            'Content-Type': 'application/json'
          },
          body: jsonEncode({'userId': sId}));

      //  print(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'Error $e',
          );
        },
      );
    }
  }
}
