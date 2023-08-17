// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../data/database.dart';
import '../../model/user_singup.dart';
import '../../utilits/routes_name.dart';
import '../../utilits/uitis.dart';
import 'addappointment.dart';

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  var _mybox = Hive.box('user');

  User userinfo = User();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_mybox.get('USER') == null) {
      userinfo.userloging();
    } else {
      userinfo.userAdd();
    }
  }

  var namecontoller = TextEditingController();
  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();
  var loading = false;

  @override
  void signUpApi(String name, String email, String password) async {
    final bool? isValid = _formKey.currentState?.validate();
    if (isValid == true) {
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

          UserSingup user = UserSingup.fromJson(userJson);
          userinfo.userData.add([user.id, user.name, user.email]);
          userinfo.userAdd();

          setState(() {});
          Navigator.pushReplacementNamed(context, RoutesName.Addappointment,
              arguments: {'name': name});
        } else {
          loading = false;
          return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Somethig went wrong.. '),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
      width: 300,
      // height: 100,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Sing Up',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
            ),
            TextFormField(
              controller: namecontoller,
              decoration: myInput(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                if (value.trim().length < 4) {
                  return 'Username must be at least 4 characters in length';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: emailcontoller,
              decoration: myInput(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                // Check if the entered email has the right format
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: passwordcontoller,
              obscureText: true,
              decoration: myInput(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                if (value.trim().length < 8) {
                  return 'Password must be at least 8 characters in length';
                }
                // Return null if the entered password is valid
                return null;
              },
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                signUpApi(
                    namecontoller.text.toString(),
                    emailcontoller.text.toString(),
                    passwordcontoller.text.toString());
              },
              child: loading ? CircularProgressIndicator() : Text("SignUp"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("go to Login")),
          ],
        ),
      ),
    )));
  }
}
