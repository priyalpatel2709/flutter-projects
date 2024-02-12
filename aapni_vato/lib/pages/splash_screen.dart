// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../data/database.dart';
import '../model/appInfo_model.dart';
import '../notifications/nodificationservices.dart';
import '../route/routes_name.dart';
import '../services/services.dart';
import '../utilits/miscellaneous.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({Key? key}) : super(key: key);

  @override
  _Splash_ScreenState createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen>
    with SingleTickerProviderStateMixin {
  final _mybox = Hive.box('user_info');
  late AnimationController _controller;
  late Animation _animation;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final Uri toLaunch =
      Uri(scheme: 'https', host: 'download-apk.onrender.com', path: '/');

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Update'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('New Version is avelable please update the app'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                launchInBrowser(toLaunch);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _controller =
        AnimationController(duration: const Duration(seconds: 4), vsync: this);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceIn),
    );
    _controller.forward().then((value) {
      wharetogo();
    });
  }

  void wharetogo() async {
    await initConnectivity();
    appupdatedialog();

    if (_connectionStatus == ConnectivityResult.none) {
      _switchToScreen(RoutesName.OfflineScreen);
    } else {
      final user = _mybox.get("user");
      if (user == null) {
        _switchToScreen(RoutesName.Login);
      } else {
        _switchToScreen(RoutesName.Chatpage);
      }
    }
  }

  void _switchToScreen(rouename) {
    Navigator.pushReplacementNamed(context, rouename);
  }

  void appupdatedialog() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String appName = packageInfo.appName;
    AppInfo appinfo = await ChatServices.getAppinfo(appName);

    if (version != appinfo.appVresion) {
      if (int.tryParse(appinfo.appUpdateVersion) == 1) {
        print('show pop-up for update');
        _showMyDialog();
      } else if (int.tryParse(appinfo.appforceUpdateVersion) == 1) {
        print('update force-fully');
        _switchToScreen(RoutesName.updatetheapp);
      }
    }
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('error:- $e');
      }
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Container(
                height: 200,
                width: 200,
                transform:
                    Matrix4.translationValues(0, -_animation.value * 100, 100),
                child: Image.asset('assets/img/mainlogo.png', scale: 0.8),
              ),
            ),
            //SizedBox(height: 20),
            const Text(
              'Appni Vato',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
