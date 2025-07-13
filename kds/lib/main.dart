import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kds/providers/order_item_state_provider.dart';
import 'package:kds/views/pages/schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'constant/constants.dart';
import 'providers/appsettings_provider.dart';
import 'providers/items_details_provider.dart';
import 'providers/order_item_state_provider.dart';
import 'views/pages/front_dask_screen.dart';
import 'views/pages/multiorder_screen.dart';
import 'views/pages/station_screen.dart';
import 'views/pages/expo_screen.dart';

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      runApp(const MyApp());
    },
    (error, stack) {
      // Log the error to a logging service
      debugPrint('Uncaught error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
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
        home: const MainScreen(),
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
  HubConnection? _connection;
  Timer? _reconnectTimer;
  static const List<Widget> _screens = <Widget>[
    MultiStationView(),
    StationScreen(),
    ExpoView(),
    FrontDeskView(),
    ScheduleView()
  ];

  Future<void> connectToSignalR(KDSItemsProvider kdsProvider,
      OrderItemStateProvider orderItemStateProvider, int storeId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      debugPrint('SignalR already connected');
      return;
    }

    _connection = HubConnectionBuilder()
        .withUrl('${KdsConst.signalRApiUrl}${KdsConst.signalRApiEndPoint}')
        // .withAutomaticReconnect()
        .build();
    // _connection?.on(KdsConst.newOrderEvent, (arguments) {
    //   log('arguments ==>$arguments');
    //   if (arguments != null && arguments.isNotEmpty) {
    //     // kdsProvider.getNewItem(orderId: arguments[0].toString());
    //   }
    // });
    try {
      await _connection!.start();
      debugPrint('SignalR Connected');
      await orderItemStateProvider.connectSignalR(_connection!);
      orderItemStateProvider.addHubConnection(
          _connection?.state ?? HubConnectionState.Disconnected);

      _connection!.onclose((error) {
        debugPrint("Connection Closed: $error");
        _handleConnectionError(kdsProvider, orderItemStateProvider, storeId);
      });
      _connection?.invoke(KdsConst.joinGroup, args: [(storeId.toString())]);

      // _connection!.onreconnecting(({error}) {
      //   debugPrint("Attempting to reconnect: $error");
      // });

      // _connection!.onreconnected(({connectionId}) {
      //   debugPrint("Reconnected with ID: $connectionId");
      //   kdsProvider.connectSignalR(_connection!);
      // });
    } catch (e) {
      debugPrint('Error connecting to SignalR: $e');
      _handleConnectionError(kdsProvider, orderItemStateProvider, storeId);
    }
  }

  void _handleConnectionError(KDSItemsProvider kdsProvider,
      OrderItemStateProvider orderItemStateProvider, int storeId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connectToSignalR(kdsProvider, orderItemStateProvider, storeId);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeApp());
  }

  @override
  void dispose() {
    _connection?.stop();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      final appSettingsProvider =
          Provider.of<AppSettingStateProvider>(context, listen: false);
      final kdsProvider = Provider.of<KDSItemsProvider>(context, listen: false);
      final orderItemStateProvider =
          Provider.of<OrderItemStateProvider>(context, listen: false);

      await connectToSignalR(
          kdsProvider, orderItemStateProvider, appSettingsProvider.storeId);

      if (_connection != null) {
        // await _connection?.invoke('JoinStoreGroup', args: <Object>['1']);

        listenToNewOrder(kdsProvider);
        listenToUpdateOrder(kdsProvider);
        listenToInjury(appSettingsProvider);
      }

      await appSettingsProvider.initializeSettings(context);
      kdsProvider.startFetching(
        timerInterval: KdsConst.timerInterval,
        storeId: appSettingsProvider.storeId,
      );

      await kdsProvider.fetchKDSStations(storeId: appSettingsProvider.storeId);
      kdsProvider.test();
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'An error occurred while initializing the app. Please try again.')),
      );
    }
  }

  void listenToNewOrder(KDSItemsProvider kdsProvider) {
    _connection?.on(KdsConst.newOrderEvent, (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        kdsProvider.getNewItem(orderId: arguments[0].toString());
      }
    });
  }

  void listenToUpdateOrder(KDSItemsProvider kdsProvider) {
    _connection?.on(KdsConst.updateNewOrderEvent, (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        kdsProvider.getNewItem(orderId: arguments[1].toString());
      }
    });
  }

  void listenToInjury(AppSettingStateProvider appSettingStateProvider) {
    _connection?.on(KdsConst.orderInquired, (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        if (appSettingStateProvider.selectedIndexPage == 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Waiting for Bag For: ${arguments[1]} ${arguments[2]} '),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingStateProvider>(
      builder:
          (BuildContext context, AppSettingStateProvider value, Widget? child) {
        return Scaffold(
          body: IndexedStack(
            index: value.selectedIndexPage,
            children: _screens,
          ),
        );
      },
    );
  }
}
