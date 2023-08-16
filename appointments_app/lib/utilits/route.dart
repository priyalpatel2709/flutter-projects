import 'package:flutter/material.dart';

import '../pages/Admin-pages/adduserinfo.dart';
import '../pages/Admin-pages/getuser.dart';
import '../pages/User-Pages/addappointment.dart';
import '../pages/User-Pages/getAppointments.dart';
import '../pages/User-Pages/login.dart';
import '../pages/User-Pages/singup.dart';
import '../pages/User-Pages/splashscreen.dart';
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
        return MaterialPageRoute(builder: (context) => Addappointment(data: settings.arguments as Map));

      case RoutesName.GetAppointments:
        return MaterialPageRoute(builder: (context) => GetAppointments());

      case RoutesName.Login:
        return MaterialPageRoute(builder: (context) => Login());

      case RoutesName.Singup:
        return MaterialPageRoute(builder: (context) => Singup());

      case RoutesName.Splashscreen:
        return MaterialPageRoute(builder: (context) => Splashscreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text("No route found")),
          ),
        );
    }
  }
}
