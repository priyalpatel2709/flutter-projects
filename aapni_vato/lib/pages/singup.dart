// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/usersingup_model.dart';

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _conformpassController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Singup'),
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Type something...',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Type something...',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Type something...',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                controller: _conformpassController,
                decoration: InputDecoration(
                  labelText: 'comform password',
                  hintText: 'Type something...',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.toString();
                  final email = _emailController.text.toString();
                  final password = _passwordController.text.toString();
                  final conformpassword =
                      _conformpassController.text.toString();

                  if (name != '' &&
                      email != '' &&
                      password != '' &&
                      conformpassword != '') {
                    print(password);
                    print(conformpassword);
                    if (password == conformpassword) {
                      singupuser(name, email, password);
                    } else {
                      print('password does not match');
                    }
                  }
                },
                child: Text('Sing-Up'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void singupuser(String name, String email, String password) async {
    try {
      var responce = await http.post(
        Uri.parse('https://single-chat-app.onrender.com/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );
      final jsonData = jsonDecode(responce.body);
      UserSingUp user = UserSingUp.fromJson(jsonData);
      print(user.name);
    } catch (e) {
      print('Error:- $e');
    }
  }
}
