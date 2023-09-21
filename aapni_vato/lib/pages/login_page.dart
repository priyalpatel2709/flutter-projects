// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/userlogin_model.dart';
import '../model/usersingup_model.dart';
import '../notifications/nodificationservices.dart';
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
  String deviceToken = '';
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.getDeviceToken().then((value) {
      deviceToken = value;
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          width: 300,
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTextField(_emailController, 'Enter Email',
                        Icons.perm_identity_sharp, 'e.g. raj123@gmail.com'),
                    SizedBox(height: 8.0),
                    _buildTextField(_passwordController, 'Enter Password',
                        Icons.password, 'e.g. Raj@Patel_23454'),
                    SizedBox(height: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        final email = _emailController.text;
                        final password = _passwordController.text;
                        if (email.isNotEmpty && password.isNotEmpty) {
                          loginuser(email, password,context);
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
                        onPressed: () async {
                          try {
                            if (_emailController.text.toString() != '') {
                              final responce = await http.get(
                                Uri.parse(
                                    'http://10.0.2.2:2709/api/user/forgotPassword/${_emailController.text.toString()}'),
                                headers: {'Content-Type': 'application/json'},
                              );

                              print(responce.body);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ErrorDialog(
                                    title: 'Fail',
                                    message: 'Enter Email...',
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Text('Forget Password ?',style: TextStyle(color: Colors.white),)),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Singup()),
                          );
                        },
                        child: Text('go to singup',
                            style: TextStyle(color: Colors.white)))
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String hintText) {
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

  Future<void> loginuser(String email, String password, BuildContext context) async {
    loading = true;
    setState(() {});
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:2709/api/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'email': email, 'password': password, 'deviceToken': deviceToken}),
      );
      if (response.statusCode == 200) {
        loading = false;
        setState(() {});
        final jsonData = await jsonDecode(response.body);
        final user = UserSingUp.fromJson(jsonData);
        User newUser = User(
          userId: user.sId.toString(),
          token: user.token.toString(),
          name: user.name.toString(),
          email: user.email.toString(),
          imageUrl: user.pic.toString(),
          deviceToken: user.deviceToken.toString(),
        );

        userData.addUserInfo(newUser);
        navigateToChatpage(context);
      } else {
        loading = false;
        setState(() {});
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: 'Fail',
              message: 'Something went wrong ${response.statusCode}',
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

  void navigateToChatpage(context) {
    Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
  }
}
