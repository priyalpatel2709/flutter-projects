import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:school_pdf/screen/admin_add_file_screen.dart';

import 'constants/app_theme.dart';
import 'services/payment_service.dart';
import 'screen/auth_wrapper.dart';
import 'screen/drivefiles_screen.dart';
import 'screen/home_screen.dart';
import 'screen/profile_screen.dart';
import 'screen/referral_screen.dart';
import 'screen/selection_screen.dart';
import 'screen/payment_example_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  
  // Initialize payment service
  PaymentService.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Friend',
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

          case '/payment':
            return MaterialPageRoute(builder: (_) => PaymentExampleScreen());

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
