import 'package:flutter/material.dart';

import '../Admin-pages/adduserinfo.dart';
import '../Admin-pages/getuser.dart';
import 'routes_name.dart';

class Routes {
  late RoutesName routesName;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.Getuser:
        return MaterialPageRoute(builder: (context) => Getuser());

      case RoutesName.Adduserinfo:
        return MaterialPageRoute(builder: (context) => Adduserinfo());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("No route found")),
          ),
        );
    }
  }
}
