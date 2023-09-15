// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'data/useradpater.dart';
import 'provider/seletedchat.dart';
import 'route/route.dart';
import 'route/routes_name.dart';

void main() async {
  Hive.registerAdapter(UserAdapter());
  await Hive.initFlutter();
  await Hive.openBox('user_info');
  runApp(
    ChangeNotifierProvider(
      create: (context) => SelectedChat(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 24,26,32)),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.Splash_Screen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

