// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../uiti/uiti.dart';
import 'chat_page.dart';

// import '../Models/user_login.dart';
// import '../Models/user_singup.dart';
// import '../data/database.dart';
// import '../uiti/uiti.dart';
// import 'login.dart';
// import 'product__list.dart';

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  var namecontoller = TextEditingController();
  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();
  var loading = false;

  @override
  void signUpApi(String name, String email, String password) async {
    loading = true;
    setState(() {});

    try {
      final response = await http.post(
        Uri.parse('https://srever-ecomm.vercel.app/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        loading = false;
        final jsonData = jsonDecode(response.body);
        final userJson = jsonData['user'];
        // final authJson = jsonData['auth'];
        // print('User Email: ${user.email}');
        setState(() {});
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Chat_page(
                      userName: name,
                    )));
        // print(authData);
      } else {
        loading = false;
        setState(() {
        });
        final jsonData = jsonDecode(response.body);
        final userJson = jsonData['result'];
        loading = false;
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Somethig went wrong..'),
              content: Text(userJson),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Ok'))
              ],
            );
          },
        );
      }
    } catch (e) {
      loading = false;
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Somethig went wrong.. $e'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok'))
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Chat-App'),
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Container(
                width: 300,
                // height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sing Up',
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Divider(),
                    Container(
                      width: 300, // 25vmax equivalent
                      margin: EdgeInsets.all(2 *
                          MediaQuery.of(context).size.width /
                          100), // 2vmax equivalent
                      child: TextField(
                        controller: namecontoller,
                        style: TextStyle(
                          fontSize: 15, // 1.2vmax equivalent
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200], // background-color
                          hintText: 'Enter Name...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                          ),
                          contentPadding: EdgeInsets.all(1.5 *
                              MediaQuery.of(context).size.width /
                              100), // 1.5vmax equivalent
                        ),
                      ),
                    ),
                    Container(
                      width: 300, // 25vmax equivalent
                      margin: EdgeInsets.all(2 *
                          MediaQuery.of(context).size.width /
                          100), // 2vmax equivalent
                      child: TextField(
                        controller: emailcontoller,
                        style: TextStyle(
                          fontSize: 15, // 1.2vmax equivalent
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200], // background-color
                          hintText: 'Enter Email...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                          ),
                          contentPadding: EdgeInsets.all(1.5 *
                              MediaQuery.of(context).size.width /
                              100), // 1.5vmax equivalent
                        ),
                      ),
                    ),
                    Container(
                      width: 300, // 25vmax equivalent
                      margin: EdgeInsets.all(2 *
                          MediaQuery.of(context).size.width /
                          100), // 2vmax equivalent
                      child: TextField(
                        obscureText: true,
                        controller: passwordcontoller,
                        style: TextStyle(
                          fontSize: 15, // 1.2vmax equivalent
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200], // background-color
                          hintText: 'Enter Password...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                          ),
                          contentPadding: EdgeInsets.all(1.5 *
                              MediaQuery.of(context).size.width /
                              100), // 1.5vmax equivalent
                        ),
                      ),
                    ),
                    Container(
                      width: 300,
                      padding: EdgeInsets.all(1.5 *
                          MediaQuery.of(context).size.width /
                          100), // 1.5vmax equivalent
                      child: ElevatedButton(
                        onPressed: () {
                          signUpApi(
                              namecontoller.text.toString(),
                              emailcontoller.text.toString(),
                              passwordcontoller.text.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 237, 20, 61), // background-color
                          padding:
                              EdgeInsets.zero, // No padding inside the button
                          shape: RoundedRectangleBorder(
                            // No border
                            borderRadius: BorderRadius.circular(0),
                          ),
                          textStyle: TextStyle(
                            color: Colors.white, // text color
                            fontFamily: "Roboto",
                            fontSize: 15, // 1.2vmax equivalent
                          ),
                          elevation: 0, // No elevation
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // Reduce tap area
                        ),
                        child: loading
                            ? CircularProgressIndicator()
                            : Text(
                                'Sing Up',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Go To Login",
                            style: TextStyle(color: Colors.white))),
                  ],
                ),
              )));
  }
}
