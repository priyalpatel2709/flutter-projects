import 'package:flutter/material.dart';

import 'pages/MyHomePage.dart';
import 'pages/Second_screen.dart';
import 'pages/Third_screen.dart';
import 'utils/route.dart';
import 'utils/routes_name.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 58, 137, 183)),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.MyHomePage,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}

