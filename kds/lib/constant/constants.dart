import 'dart:ui';

import 'package:flutter/material.dart';

class KdsConst {
  KdsConst._();

  //API URL
  static const String apiUrl = 'https://storesposapi.azurewebsites.net/api/';

  //API ENDPOINT
  static const String getKDSStations = 'GetKDSStationsdetails';
  static const String getKDSItems = 'GetKDSItemsdetails';
  static const String updateKDSItemStatus = 'UpdateKDSItemstatus';

  static const int timerInterval = 10;
  static const int storeId = 1;

  //filters values
  static const String defaultFilter = 'In Progress';
  static const String doneFilter = 'Done';
  static const String allFilter = 'All';

  //order type
  static const String pickup = 'Pickup';
  static const String delivery = 'Delivery';
  static const String dineIn = 'Dine-In';
  static const String oBPickup = 'OB-Pickup';

  //view type
  static const String list = 'List';
  static const String grid = 'Grid';
  static const String fixedGrid = 'Fixed Grid';

  //new Colors

  static const Color mainColor = Color.fromARGB(213, 243, 180, 62);

  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color black = Color.fromARGB(255, 0, 0, 0);

  //Button Colors
  static const Color red = Color.fromARGB(255, 239, 90, 111); //Undo
  static const Color darkGreen = Color.fromARGB(255, 133, 230, 197); // All Done
  static const Color grey = Color.fromARGB(255, 148, 181, 199); //Start
  static const Color green =
      Color.fromARGB(255, 127, 165, 153); //complete state

  //Label Text Colors
  static const Color orange = Color.fromARGB(255, 255, 131, 67); // In Progress
  static const Color completedTextGreen =
      Color.fromARGB(255, 79, 175, 80); //Completed

  //Order Type Colors
  static const Color dineInColor = Color.fromARGB(255, 182, 207, 182);
  static const Color pickUpColor = Color.fromARGB(255, 255, 175, 165);
  static const Color deliveryColor = Color.fromARGB(255, 212, 240, 240);

  //screen names
  static const String multiStationScreen = 'Chef MultiStation Screen';
  static const String singleStationScreen = 'Chef Station Screen';
  static const String expoScreen = 'Expo Screen';
}
