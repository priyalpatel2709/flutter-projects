// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/usersingup_model.dart';
import '../route/routes_name.dart';
import '../utilits/errordialog.dart';
import 'chat_page.dart';
import 'login_page.dart';

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpassController = TextEditingController();
  UserInfo userData = UserInfo();
  var loading = false;

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: Colors.white, width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: Colors.white24, width: 2)),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white10),
        prefixIcon: Icon(icon),
        border:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        title: Text('Singup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          width: 300,
          child: loading
              ? Center(
                  child: Text('Loading'),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextField(
                        _nameController, 'name', Icons.perm_identity_sharp,'e.g. Raj'),
                    SizedBox(
                      height: 8.0,
                    ),
                    _buildTextField(_emailController, 'email', Icons.email,'e.g. raj123@gmail.com'),
                    SizedBox(
                      height: 8.0,
                    ),
                    _buildTextField(
                        _passwordController, 'password', Icons.password,'e.g. Raj@Patel_23454'),
                    SizedBox(
                      height: 8.0,
                    ),
                    _buildTextField(_confirmpassController, 'confirm password',
                        Icons.password,'e.g. Raj@Patel_23454'),
                    SizedBox(
                      height: 8.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final name = _nameController.text.toString();
                        final email = _emailController.text.toString();
                        final password = _passwordController.text.toString();
                        final conformpassword =
                            _confirmpassController.text.toString();

                        if (name != '' &&
                            email != '' &&
                            password != '' &&
                            conformpassword != '') {
                          if (password == conformpassword) {
                            singupuser(name, email, password);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ErrorDialog(
                                  title: 'Fail',
                                  message: 'password does not match !!',
                                );
                              },
                            );
                          }
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                title: 'Fail',
                                message: 'Enter all fields',
                              );
                            },
                          );
                        }
                      },
                      child: Text('Sing-Up'),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Text(
                          'go to singup',
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
        ),
      ),
    );
  }

  void singupuser(String name, String email, String password) async {
    loading = true;
    setState(() {});

    try {
      loading = false;
      setState(() {});
      var response = await http.post(
        Uri.parse('https://single-chat-app.onrender.com/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 200) {
        final jsonData = await jsonDecode(response.body);
        UserSingUp user = UserSingUp.fromJson(jsonData);

        // Create a User object with the retrieved information
        User newUser = User(
          userId: user.sId.toString(),
          token: user.token.toString(),
          name: user.name.toString(),
          email: user.email.toString(),
          imageUrl: user.pic.toString(),
        );

        // Store the user in Hive
        userData.addUserInfo(newUser);

        navigateToChatpage();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: 'Fail',
              message: 'User Already Exists !!!',
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
            message: 'Error: $e',
          );
        },
      );
    }
  }

  void navigateToChatpage() {
    Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
  }
}
