import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/items_details_provider.dart';
import 'providers/order_item_state_provider.dart';
import 'views/expo_screen.dart';
import 'views/station_screen.dart';

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
    StationScreen(), // Station screen
    ExpoScreen(), // Expo screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Change selected screen index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Set the selected tab
        onTap: _onItemTapped, // Change screen on tap
        selectedItemColor: Colors.amber[800],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Stations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Expo',
          ),
        ],
      ),
    );
  }
}
