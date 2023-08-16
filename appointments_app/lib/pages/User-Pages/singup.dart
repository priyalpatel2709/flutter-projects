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
        // print('User Email: ${user.email}');
        setState(() {});
        Navigator.pushReplacementNamed(context,RoutesName.Addappointment,arguments: {'name': name} );
        // print(authData);
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
          Text(
            'Sing Up',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
          ),
          TextField(
            controller: namecontoller,
            decoration: myInput(labelText: 'Name'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: emailcontoller,
            decoration: myInput(labelText: 'Email'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: passwordcontoller,
            decoration: myInput(labelText: 'Password'),
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
    )));
  }
}
