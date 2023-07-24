// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

import '../Models/user_login.dart';
import '../data/database.dart';
import 'demopage.dart';
import 'product_list.dart';
import 'singup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  var _mybox = Hive.box('user');

  User  userinfo = User();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(_mybox.get('USER') == null){
      userinfo.userlogin();
    }else{
      userinfo.addUser();
      // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> Demopage()) );
    }
  }


  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();

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
          TextField(
            controller: emailcontoller,
            decoration: InputDecoration(
              hintText: 'Enter your Email...',
              labelText: 'Hello',
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: const Color.fromARGB(255, 92, 168, 94), width: 1)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color.fromARGB(255, 78, 144, 231), width: 1)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color.fromARGB(255, 87, 82, 82), width: 1)),
              suffixIcon: Icon(Icons.email),
              prefixIcon: Icon(Icons.person)
            ),
          ),
          SizedBox(
            height: 12,
          ),
          TextField(
              // enabled: false,
              controller: passwordcontoller,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Enter your Password...',
                focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(11),
                 borderSide: BorderSide(color: const Color.fromARGB(255, 92, 168, 94), width: 1)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color.fromARGB(255, 78, 144, 231), width: 1)),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color.fromARGB(255, 87, 82, 82), width: 1)),
                suffix: IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    onPressed: () {
                    print('show password');
                  },
                )  ,      
                prefixIcon: Icon(Icons.lock)
          )
          ),
          SizedBox(
            height: 12,
          ),
          ElevatedButton(
              onPressed: () {
                login(emailcontoller.text.toString(),
                    passwordcontoller.text.toString());
              },
              child: Text('Login')),
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
        )
      )
    );
  }

  void login(email, password) async {
    try {
      final response =
          await http.post(Uri.parse('https://srever-ecomm.vercel.app/login'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final userJson = jsonData['user'];
        UserLonin user = UserLonin.fromJson(userJson);

        print('User Name: ${user.name}');
        
        setState(() {
          userinfo.userData.add([user.id,user.name,user.email]);
        });
        userinfo.addUser();
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> ProductList()) );
      } else {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Somethig went wrong..'),
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
}
