import 'package:flutter/material.dart';
import 'package:kds/views/multiorder_screen.dart';
import 'package:kds/views/station_screen.dart';
import 'package:provider/provider.dart';
import 'constant/constants.dart';
import 'providers/appsettings_provider.dart';
import 'providers/items_details_provider.dart';
import 'providers/order_item_state_provider.dart';
import 'views/expo_screen.dart';
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
        ChangeNotifierProvider(create: (_) => AppSettingStateProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                OrderItemStateProvider(kdsItemsProvider: KDSItemsProvider())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KDS App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: KdsConst.mainColor),
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
    MultiStationView(),
    StationScreen(),
    ExpoView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Call initializeSettings after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appSettingsProvider =
          Provider.of<AppSettingStateProvider>(context, listen: false);
      appSettingsProvider.initializeSettings(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingStateProvider>(
      builder:
          (BuildContext context, AppSettingStateProvider value, Widget? child) {
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: LayoutBuilder(
            builder: (context, constraints) {
              return BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: KdsConst.mainColor,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.view_list),
                    label: 'Multi Station',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business),
                    label: 'Stations',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.done_all),
                    label: 'Expo',
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}
