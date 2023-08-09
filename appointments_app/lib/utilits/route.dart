import 'package:flutter/material.dart';

import '../pages/Admin-pages/adduserinfo.dart';
import '../pages/Admin-pages/getuser.dart';
import '../pages/User-Pages/addappointment.dart';
import 'routes_name.dart';

class Routes {
  late RoutesName routesName;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.Getuser:
        return MaterialPageRoute(builder: (context) => Getuser());

      case RoutesName.Adduserinfo:
        return MaterialPageRoute(builder: (context) => Adduserinfo());

      case RoutesName.Addappointment:
        return MaterialPageRoute(builder: (context) => Addappointment());


      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("No route found")),
          ),
        );
    }
  }
}
