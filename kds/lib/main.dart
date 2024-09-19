import 'package:flutter/material.dart';
import 'package:kds/views/expo_screenV2.dart';
import 'package:kds/views/station_screenV2.dart';
import 'package:provider/provider.dart';
import 'providers/items_details_provider.dart';
import 'providers/order_item_state_provider.dart';
// import 'views/expo_screen.dart';
// import 'views/station_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KDSItemsProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                OrderItemStateProvider(kdsItemsProvider: KDSItemsProvider())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KDS App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xfff3b33e)),
          useMaterial3: true,
        ),
        home: const MainScreen(), // Entry point to main screen
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    // ExpoScreen(), // Expo screen
    // StationScreen(), // Station screen

    // ? V2
    StationScreenV2(), // Station screen
    ExpoScreenV2(), // Expo screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;

          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.amber[800],
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(isWideScreen ? Icons.business : Icons.home),
                label: 'Stations',
              ),
              BottomNavigationBarItem(
                icon: Icon(isWideScreen ? Icons.view_list : Icons.home),
                label: 'Expo',
              ),
            ],
          );
        },
      ),
    );
  }
}
