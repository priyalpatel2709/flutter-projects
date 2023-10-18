// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_model.dart';
import 'callinfg.dart';
import 'home_page.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key? key}) : super(key: key);

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  List<StudentData> finalInfo = [];
  int count = 0;

  @override
  void initState() {
    super.initState();
    loadUsersList();
    wharetogo();
  }

  Future<void> loadUsersList() async {
    final loadedUsers = await getUsersList();
    var getCount = await getLastCallCount();

    getCount ??= 0;
    setState(() {
      finalInfo = loadedUsers;
      count = getCount!;
    });
  }

  Future<List<StudentData>> getUsersList() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = prefs.getString('userList');

    if (userListJson == null) {
      return [];
    }
    final userList = jsonDecode(userListJson) as List<dynamic>;
    return userList.map((userMap) => StudentData.fromJson(userMap)).toList();
  }

  Future<int?> getLastCallCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastCallCount');
  }

  void wharetogo() async {
    Future.delayed(Duration(seconds: 2), () {
      if (finalInfo.isNotEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CallScreen(
                      sData: finalInfo,
                      currentIndex: count,
                    )));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Homepage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('chalo kro call...',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
            Icon(Icons.phone_in_talk)
          ],
        ),
      ),
    );
  }
}
