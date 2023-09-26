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

class _Splash_ScreenState extends State<Splash_Screen>
    with SingleTickerProviderStateMixin {
  final _mybox = Hive.box('user_info');
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 4), vsync: this);


    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceIn),
      
    );
    _controller.forward().then((value) {
      wharetogo();
    });
  }

  void wharetogo() async {
    Future.delayed(Duration(milliseconds: 10), () {
      // Navigator.pushReplacementNamed(context, RoutesName.Chatpage);

      if (_mybox.get("user") == null) {
        Navigator.pushReplacementNamed(context, RoutesName.Login);
      } else {
        Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Container(
                height: 200,
                width: 200,
                transform:
                    Matrix4.translationValues(0, -_animation.value * 100, 100),
                child: Image.asset(
                  'assets/img/mainlogo.png',
                  scale: 0.8
                ),
              ),
            ),
            //SizedBox(height: 20),
            const Text(
              'Appni Vato',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
