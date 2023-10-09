import 'package:flutter/material.dart';

import 'Themes/styles.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping-App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: MyThems.ightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: MyThems.darkColorScheme,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Homepage();
  }
}
