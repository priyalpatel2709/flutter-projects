// ignore_for_file: prefer_const_constructors
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'data/useradpater.dart';
import 'provider/seletedchat.dart';
import 'route/route.dart';
import 'route/routes_name.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
  Hive.registerAdapter(UserAdapter());
  await Hive.initFlutter();
  await Hive.openBox('user_info');
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firrebacebackgroundhandler);
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => SelectedChat(),
      child: MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firrebacebackgroundhandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Appni vato',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 24, 26, 32)),
        useMaterial3: true,
      ),
      initialRoute: RoutesName.Splash_Screen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
