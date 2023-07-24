// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/user_login.dart';
import '../Models/user_singup.dart';
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
        final jsonData = jsonDecode(response.body);
        final userJson  = jsonData['user'];
        final authJson = jsonData['auth'];


        UserSingup user = UserSingup.fromJson(userJson);
        AuthData authData = AuthData.fromJson(authJson);

      print('User ID: ${user.id}');
      print('User Name: ${user.name}');
      print('User Email: ${user.email}');
      
        // print(authData);
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
              labelText: "Name",
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 92, 168, 94), width: 1)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 78, 144, 231), width: 1)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 87, 82, 82), width: 1)),
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: emailcontoller,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 92, 168, 94), width: 1)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 78, 144, 231), width: 1)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 87, 82, 82), width: 1)),
              labelText: "Email",
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordcontoller,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 92, 168, 94), width: 1)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 78, 144, 231), width: 1)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 87, 82, 82), width: 1)),
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
