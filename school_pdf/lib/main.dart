import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:school_pdf/screen/admin_add_file_screen.dart';

import 'constants/app_theme.dart';
import 'screen/auth_wrapper.dart';
import 'screen/drivefiles_screen.dart';
import 'screen/home_screen.dart';
import 'screen/profile_screen.dart';
import 'screen/referral_screen.dart';
import 'screen/selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drive File App',
      theme: AppTheme.lightTheme,
      home: AuthWrapper(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen());

          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfileScreen());

          case '/referrals':
            return MaterialPageRoute(builder: (_) => ReferralScreen());

          case '/admin':
            return MaterialPageRoute(builder: (_) => AdminAddFileScreen());

          case '/driveFiles':
            final args = settings.arguments as Map<String, dynamic>?;
            final medium = args?['medium'] ?? 'Option 2 Files';
            final module = args?['module'] ?? 'Option 2 Files';

            return MaterialPageRoute(
              builder: (_) => DriveFilesScreen(
                title: '$medium/$module',
                medium: medium,
                module: module,
              ),
            );

          case '/selection':
            return MaterialPageRoute(builder: (_) => SelectionScreen());

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}
