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

  static const int timerInterval = 20;
  static const int storeId = 1;

  //filters values
  static const String defaultFilter = 'In Progress';
  static const String doneFilter = 'Done';
  static const String allFilter = 'All';

  //colors
  static const Color mainColor = Color.fromARGB(255, 51, 119, 188);
  static const Color onMainColor = Color.fromARGB(255, 255, 255, 255);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color tryColor = Color(0xfff3b33e);

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
  static const Color grey = Color.fromARGB(255, 96, 102, 118);
  static const Color orange = Color.fromARGB(255, 255, 131, 67);
  static const Color lightGreen = Color.fromARGB(255, 190, 198, 160);
  static const Color green = Color.fromARGB(255, 133, 230, 197);
  static const Color red = Color.fromARGB(255, 239, 90, 111);
  static const Color yellow = Color.fromARGB(255, 255, 166, 47);
  static const Color blue = Color.fromARGB(255, 90, 178, 255);
  // static const Color red = Color.fromARGB(1, 239, 90, 111);
}
