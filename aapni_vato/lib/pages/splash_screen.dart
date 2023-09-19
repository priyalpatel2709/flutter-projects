// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../data/database.dart';
import '../notifications/nodificationservices.dart';
import '../route/routes_name.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({Key? key}) : super(key: key);

  @override
  _Splash_ScreenState createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  final _mybox = Hive.box('user_info');
  NotificationServices notificationServices = NotificationServices();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.reqOfNotifiction();
    notificationServices.firebaceInit();
    notificationServices.getToken().then((value){
      print(value);
    });
    wharetogo();
  }

  void wharetogo() async {
    Future.delayed(Duration(seconds: 2), () {
      // Navigator.pushReplacementNamed(context, RoutesName.Chatpage);

      if (_mybox.get("user") == null) {
        Navigator.pushReplacementNamed(context, RoutesName.Login);
      } else {
        Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77,80,85),
      appBar: AppBar(
        title: Text('Splash_Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text('This is Splash_Screen content. bla bla lla'),
      ),
    );
  }
}
