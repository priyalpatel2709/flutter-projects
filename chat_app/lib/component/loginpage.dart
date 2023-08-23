// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../uiti/uiti.dart';
import 'chat_page.dart';
import 'singup.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Loginpage> {
  var emailcontoller = TextEditingController();
  var passwordcontoller = TextEditingController();
  var loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Chat-App'),
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : Center(
                child: Container(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Log In',
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Divider(),
                    Container(
                      width: 25 *
                          MediaQuery.of(context).size.width /
                          100, // 25vmax equivalent
                      margin: EdgeInsets.all(2 *
                          MediaQuery.of(context).size.width /
                          100), // 2vmax equivalent
                      child: TextField(
                        controller: emailcontoller,
                        style: TextStyle(
                          fontSize: 1.2 *
                              MediaQuery.of(context).size.width /
                              100, // 1.2vmax equivalent
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200], // background-color
                          hintText: 'Enter Name...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                          ),
                          contentPadding: EdgeInsets.all(1.5 *
                              MediaQuery.of(context).size.width /
                              100), // 1.5vmax equivalent
                        ),
                      ),
                    ),
                    Container(
                      width: 25 *
                          MediaQuery.of(context).size.width /
                          100, // 25vmax equivalent
                      margin: EdgeInsets.all(2 *
                          MediaQuery.of(context).size.width /
                          100), // 2vmax equivalent
                      child: TextField(
                        obscureText: true,
                        controller: passwordcontoller,
                        style: TextStyle(
                          fontSize: 1.2 *
                              MediaQuery.of(context).size.width /
                              100, // 1.2vmax equivalent
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200], // background-color
                          hintText: 'Enter Password...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none, // No border
                          ),
                          contentPadding: EdgeInsets.all(1.5 *
                              MediaQuery.of(context).size.width /
                              100), // 1.5vmax equivalent
                        ),
                      ),
                    ),
                    Container(
                      width: 25 * MediaQuery.of(context).size.width / 100,
                      padding: EdgeInsets.all(1.5 *
                          MediaQuery.of(context).size.width /
                          100), // 1.5vmax equivalent
                      child: ElevatedButton(
                        onPressed: () {
                          login(emailcontoller.text.toString(),
                              passwordcontoller.text.toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 237, 20, 61), // background-color
                          padding:
                              EdgeInsets.zero, // No padding inside the button
                          shape: RoundedRectangleBorder(
                            // No border
                            borderRadius: BorderRadius.circular(0),
                          ),
                          textStyle: TextStyle(
                            color: Colors.white, // text color
                            fontFamily: "Roboto",
                            fontSize: 1.2 *
                                MediaQuery.of(context).size.width /
                                100, // 1.2vmax equivalent
                          ),
                          elevation: 0, // No elevation
                          tapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // Reduce tap area
                        ),
                        child: Text(
                          'Sing Up',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Singup()),
                          );
                        },
                        child: Text(
                          'Go To Sing Up',
                          style: TextStyle(color: Colors.white),
                        )),
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
              body: jsonEncode({'name': email, 'password': password}));

      if (response.statusCode == 200) {
        loading = false;
        // final jsonData = jsonDecode(response.body);
        // final userJson = jsonData['user'];

        setState(() {});

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Chat_page(
                      userName: email,
                    )));
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
