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
  List<StudentData> CropInfo = [];
  int count = 0;
  bool whatsappmessge = false;

  @override
  void initState() {
    super.initState();
    loadUsersList();
    wharetogo();
  }

  Future<void> loadUsersList() async {
    final loadedUsers = await getCropUsersList();
    var getCount = await getLastCallCount();
    var getiscalled = await getLastCallBool();

    getCount ??= 0;
    getiscalled ??= false;
    setState(() {
      finalInfo = loadedUsers;
      count = getCount!;
      whatsappmessge = getiscalled!;
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

  Future<List<StudentData>> getCropUsersList() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = prefs.getString('cropUsers');

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

  Future<bool?> getLastCallBool() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isCalled');
  }

  void wharetogo() async {
    Future.delayed(Duration(seconds: 2), () {
      if (finalInfo.isNotEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => CallScreen(
                      sData: finalInfo,
                      currentIndex: count, callDone: whatsappmessge,
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
