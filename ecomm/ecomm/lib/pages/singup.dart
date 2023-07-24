// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../Models/user_login.dart';
import '../Models/user_singup.dart';
import '../data/database.dart';
import 'login.dart';
import 'product__list.dart';

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
      userinfo.userlogin();
    } else {
      userinfo.addUser();
    }
  }

  var namecontoller = TextEditingController();
  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();

  @override
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
        final userJson = jsonData['user'];
        // final authJson = jsonData['auth'];

        UserSingup user = UserSingup.fromJson(userJson);
        // AuthData authData = AuthData.fromJson(authJson);
        print('User Email: ${user.email}');
        setState(() {
          userinfo.userData.add([user.id, user.name, user.email]);
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProductList()));
        // print(authData);
      } else {
       return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Somethig went wrong.. '),
              actions: [
                TextButton(onPressed: (){
                  Navigator.of(context).pop();  
                }, child: Text('Ok'))
              ],
            );
          },
        );
      }
    } catch (e) {
             return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Somethig went wrong.. $e'),
              actions: [
                TextButton(onPressed: (){
                  Navigator.of(context).pop();  
                }, child: Text('Ok'))
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
            },
            child: Text("SignUp"),
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
