import 'package:flutter/material.dart';
import 'package:img_store/utilits/imagelistprovider.dart';
import 'package:provider/provider.dart';

import 'Themes/styles.dart';
import 'pages/homepage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImageListProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: MyThems.ightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: MyThems.darkColorScheme,
      ),
      home: const Homepage(),
    );
  }
}
