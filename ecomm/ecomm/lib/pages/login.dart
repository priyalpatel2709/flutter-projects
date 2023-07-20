// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'singup.dart';

class Login extends StatefulWidget {
  const Login({ Key? key }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Column(
        children: [
          TextField(controller: emailcontoller,decoration: InputDecoration(border: OutlineInputBorder(),labelText: "Email"),),SizedBox(height: 12,),
          TextField(controller: passwordcontoller,decoration: InputDecoration(border: OutlineInputBorder(),labelText: "Password"),),SizedBox(height: 12,),
          ElevatedButton(onPressed: (){
            login(emailcontoller.text.toString(),passwordcontoller.text.toString());
          }, child: Text('Login')),
          TextButton(onPressed: (){
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> Singup()) );
          }, child: Text('Go To Sing Up'))
        ],
      ),
    );
  }
  
  void login(email,password) async {
    print('email $email');
    print('password $password');
    try{
      final response = await http.post(
        Uri.parse('https://srever-ecomm.vercel.app/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email':email,
          'password':password
        }) 
      );

      if(response.statusCode==200){
        print('Longin done');
        print(response.body);
      }else{
        print('login failed');
      }
    }catch (e){
      print('error $e');
    }

  }
}