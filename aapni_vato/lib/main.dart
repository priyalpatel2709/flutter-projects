// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'data/useradpater.dart';
import 'pages/login_page.dart';
import 'pages/singup_page.dart';
import 'pages/splash_screen.dart';
import 'route/route.dart';
import 'route/routes_name.dart';

void main() async {
  Hive.registerAdapter(UserAdapter());
  await Hive.initFlutter();
  await Hive.openBox('user_info');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.Splash_Screen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

