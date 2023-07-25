// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'pages/fav_list.dart';
import 'pages/homepage.dart';
import 'package:provider/provider.dart';
import 'pages/slider_widget.dart';
import 'provider/counter_provider.dart';
import 'provider/favlist_provider.dart';
import 'provider/sliderprovider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => countProvider()),
        ChangeNotifierProvider(create: (_) => SliderProvider()),
        ChangeNotifierProvider(create: (_) => FavListProvider()),
      ],
  
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 45, 178, 255)),
          useMaterial3: true,
        ),
        home: FavList(),
      ),
    );
  }
}
