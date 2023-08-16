// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

import '../../data/database.dart';
import '../../model/user_login.dart';
import '../../utilits/routes_name.dart';
import '../../utilits/uitis.dart';
import 'addappointment.dart';
import 'singup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var _mybox = Hive.box('user');

  User userinfo = User();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_mybox.get('USER') == null) {
      userinfo.userloging();
    } else {
      userinfo.userAdd();
      // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> Demopage()) );
    }
  }

  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();
  var loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Log In',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 12,
          ),
          TextField(
            controller: emailcontoller,
            decoration: myInput(labelText: 'Email'),
          ),
          SizedBox(
            height: 12,
          ),
          TextField(
              // enabled: false,
              controller: passwordcontoller,
              obscureText: true,
              decoration: myInput(labelText: 'PassWord')),
          SizedBox(
            height: 12,
          ),
          ElevatedButton(
              onPressed: () {
                login(emailcontoller.text.toString(),
                    passwordcontoller.text.toString());
              },
              child: loading ? CircularProgressIndicator() : Text('Login')),
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Singup()),
                );
              },
              child: Text('Go To Sing Up')),
        ],
      ),
    )));
  }

  void login(email, password) async {
    loading = true;
    setState(() {});

    try {
      final response =
          await http.post(Uri.parse('https://srever-ecomm.vercel.app/login'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        loading = false;
        final jsonData = jsonDecode(response.body);
        final userJson = jsonData['user'];
        UserLonin user = UserLonin.fromJson(userJson);
        userinfo.userData.add([user.id, user.name, user.email]);
        userinfo.userAdd();
        setState(() {});

        Navigator.pushReplacementNamed(context, RoutesName.Addappointment,
            arguments: {'name': user.name});
      } else {
        loading = false;
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Somethig went wrong..'),
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
      setState(() {});
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
