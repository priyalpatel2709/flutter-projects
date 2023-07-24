// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  var namecontoller = TextEditingController();
  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();

  void signUpApi(String name, String email, String password) async {
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
        print('Sign-up successful!');
        print('Response: ${response.body}');
      } else {
        print('Sign-up failed. Status code: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
      width: 300,
      // height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: namecontoller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Name",
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: emailcontoller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email",
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordcontoller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Password",
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              signUpApi(
                  namecontoller.text.toString(),
                  emailcontoller.text.toString(),
                  passwordcontoller.text.toString());
              print(
                  '${emailcontoller.text},${namecontoller.text},${passwordcontoller.text}');
            },
            child: Text("SignUp"),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("go to Login"))
        ],
      ),
    )));
  }
}
