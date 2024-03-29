import '../pages/add_frind.dart';
import '../pages/chat_page.dart';
import '../pages/chatmessage_page.dart';
import '../pages/groupchat.dart';
import '../pages/login_page.dart';
import '../pages/offlinescreen.dart';
import '../pages/singup_page.dart';
import '../pages/splash_screen.dart';
import '../pages/updateapppage.dart';
import 'routes_name.dart';
import 'package:flutter/material.dart';

class Routes {
  late RoutesName routesName;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.Splash_Screen:
        return MaterialPageRoute(builder: (context) => Splash_Screen());

      case RoutesName.Login:
        return MaterialPageRoute(builder: (context) => Login());

      case RoutesName.Singup:
        return MaterialPageRoute(builder: (context) => Singup());

      case RoutesName.Chatpage:
        return MaterialPageRoute(builder: (context) => Chatpage());

      case RoutesName.AddFriend:
        return MaterialPageRoute(builder: (context) => AddFriend());

      case RoutesName.Chatmessage_page:
        return MaterialPageRoute(
            builder: (context) =>
                Chatmessage_page(data: settings.arguments as Map));

      case RoutesName.Groupchat:
        return MaterialPageRoute(builder: (context) => Groupchat());

      case RoutesName.OfflineScreen:
        return MaterialPageRoute(builder: (context) => Offlinescreen());

      case RoutesName.updatetheapp:
        return MaterialPageRoute(builder: (context) => Updateapppage());

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("No route found")),
          ),
        );
    }
  }
}
