// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _Emailcontroller = TextEditingController();
  final TextEditingController _Passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _Emailcontroller,
                decoration: InputDecoration(
                  labelText: 'Enter Email',
                  hintText: 'Type something...',
                  prefixIcon: Icon(Icons.perm_identity_sharp),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _Passwordcontroller,
                decoration: InputDecoration(
                  labelText: 'Enter Password',
                  hintText: 'Type something...',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              ElevatedButton(
                onPressed: () {
                  var email = _Emailcontroller.text;
                  var password = _Passwordcontroller.text;
                  if (email != '' && password != '') {
                    loginuser(email, password);
                  }
                },
                child: Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginuser(String email, String password) async {
    var response = await http.post(Uri.parse('https://single-chat-app.onrender.com/api/user/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}));
         final jsonData = jsonDecode(response.body);
        print(jsonData);
  }
}
