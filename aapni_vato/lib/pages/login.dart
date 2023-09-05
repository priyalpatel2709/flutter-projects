import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/userlogin_model.dart';
import 'chatpage.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  UserInfo userData = UserInfo();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              _buildTextField(_emailController, 'Enter Email', Icons.perm_identity_sharp),
              SizedBox(height: 8.0),
              _buildTextField(_passwordController, 'Enter Password', Icons.password),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  if (email.isNotEmpty && password.isNotEmpty) {
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Type something...',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> loginuser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://single-chat-app.onrender.com/api/user/login'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final user = UserLogIn.fromJson(jsonData);

        userData.user_info.addAll([user.sId, user.token, user.name, user.email]);
        userData.addUser();
        navigateToChatpage();
      } else {
        print('Something went wrong');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void navigateToChatpage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Chatpage()),
    );
  }
}
