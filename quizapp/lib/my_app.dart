// my_app.dart

import 'package:flutter/material.dart';

import 'viewmodels/app_viewmodel.dart';
import 'views/home_screen.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Quiz App',
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: AppViewModel.primaryColor),
          useMaterial3: true,
        ),
        home: HomeScreen());
  }
}
