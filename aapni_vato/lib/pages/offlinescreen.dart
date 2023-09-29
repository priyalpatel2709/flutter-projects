// ignore_for_file: prefer_const_constructors,

import 'package:flutter/material.dart';

import '../route/routes_name.dart';

class Offlinescreen extends StatelessWidget {
  const Offlinescreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      body: Center(
        child: InkWell(
          onTap: (){
            Navigator.pushReplacementNamed(context, RoutesName.Splash_Screen);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.wifi_off_outlined,
                size: 100,
                color: Colors.white30,
              ),
              Text('You are Offline....',style: TextStyle(color: Colors.white30),)
            ],
          ),
        ),
      ),
    );
  }
}
