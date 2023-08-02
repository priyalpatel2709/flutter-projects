// import 'dart:js';

import 'package:flutter/material.dart';

import '../pages/MyHomePage.dart';
import '../pages/NewScreen.dart';
import '../pages/second_screen.dart';
import '../pages/third_screen.dart';
import 'routes_name.dart';

class Routes {
  late RoutesName routesName;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.MyHomePage:
        return MaterialPageRoute(builder: (context) => MyHomePage());

      case RoutesName.SecondScreen:
        return MaterialPageRoute(
            builder: (context) =>
                SecondScreen(data: settings.arguments as Map));

      case RoutesName.ThirdScreen:
        return MaterialPageRoute(
            builder: (context) => ThirdScreen(data: settings.arguments as Map));

      case RoutesName.NewScreen :
        return MaterialPageRoute(
          builder: (context)=> NewScreen(data : settings.arguments as Map));
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("No route found")),
          ),
        );
    }
  }
}
