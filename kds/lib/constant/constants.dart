import 'dart:ui';

import 'package:flutter/material.dart';

class KdsConst {
  KdsConst._();

  static const int timerInterval = 20;
  static const int storeId = 1;

  //filters values
  static const String defaultFilter = 'In Progress';
  static const String doneFilter = 'Done';

  //colors
  static const Color mainColor = Color.fromARGB(255, 51, 119, 188);
  static const Color onMainColor = Color.fromARGB(255, 255, 255, 255);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color tryColor = Color(0xfff3b33e);

  //order type
  static const String pickup = 'Pickup';
  static const String delivery = 'Delivery';
  static const String dineIn = 'Dine-In';

  //view type
  static const String list = 'List';
  static const String grid = 'Grid';
  static const String fixedGrid = 'Fixed Grid';
}
