// ignore_for_file: prefer_const_constructors,

import 'package:flutter/material.dart';

import '../route/routes_name.dart';

class Offlinescreen extends StatelessWidget {
  const Offlinescreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple, Colors.orange])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: InkWell(
            onTap: () {
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
                Text(
                  'You are Offline....',
                  style: TextStyle(color: Colors.white30),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
