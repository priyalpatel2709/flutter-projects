// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref extends StatefulWidget {
  const SharedPref({Key? key}) : super(key: key);

  @override
  _SharedPrefState createState() => _SharedPrefState();
}

class _SharedPrefState extends State<SharedPref> {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getvalue();
  }

  var nameValue = 'no data';
  var passwordValue = 'no data';
  var emailValue = 'no data';
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Color(0xffE6E6E6),
            radius: 30,
            child: Icon(Icons.person),
          ),
          SizedBox(height: 11,),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 11,),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 11,),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 6,),
          ElevatedButton(
            onPressed: () async {
              var pref = await SharedPreferences.getInstance();

              pref.setString('userName', nameController.text.toString());
              pref.setString(
                  'userPassword', passwordController.text.toString());
              pref.setString('userEmail', emailController.text.toString());
            },
            child: Text('Save'),
          ),
          SizedBox(height: 3,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text('Name'),
          Text('Email'),
          Text('Password'),
            ],
          ),
          SizedBox(height: 3,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text(nameValue),
          Text(emailValue),
          Text(passwordValue),
            ],
          ),

        ],
      ),
    ));
  }

  void getvalue() async {
    var pref = await SharedPreferences.getInstance();

    var preName = pref.getString('userName');
    var userPassword = pref.getString('userPassword');
    var userEmail = pref.getString('userEmail');

    nameValue = preName ?? 'no name';
    passwordValue = userPassword ?? 'no Passwod';
    emailValue = userEmail ?? 'no Email';

    setState(() {});
  }
}
