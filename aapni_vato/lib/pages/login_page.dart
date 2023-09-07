// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/userlogin_model.dart';
import '../route/routes_name.dart';
import '../utilits/errordialog.dart';
import 'chat_page.dart';
import 'singup_page.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  UserInfo userData = UserInfo();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77,80,85),
      appBar: AppBar(
        title: Text('Login'),
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
                    _buildTextField(_emailController, 'Enter Email',
                        Icons.perm_identity_sharp),
                    SizedBox(height: 8.0),
                    _buildTextField(
                        _passwordController, 'Enter Password', Icons.password),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        final email = _emailController.text;
                        final password = _passwordController.text;
                        if (email.isNotEmpty && password.isNotEmpty) {
                          loginuser(email, password);
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
                      child: Text('Log In'),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Singup()),
                          );
                        },
                        child: Text('go to singup'))
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Type something...',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24)
        ),
      ),
    );
  }

  Future<void> loginuser(String email, String password) async {
    loading = true;
    setState(() {});
    try {
      loading = false;
      setState(() {});
      final response = await http.post(
        Uri.parse('https://single-chat-app.onrender.com/api/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final jsonData = await jsonDecode(response.body);
        final user = UserLogIn.fromJson(jsonData);
        User newUser = User(
          userId: user.sId.toString(),
          token: user.token.toString(),
          name: user.name.toString(),
          email: user.email.toString(),
        );
        userData.addUserInfo(newUser);
        navigateToChatpage();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: 'Fail',
              message: 'Something went wrong',
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
            title: 'Error',
            message: 'Error:- $e',
          );
        },
      );
    }
  }

  void navigateToChatpage() {
    Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
  }
}
