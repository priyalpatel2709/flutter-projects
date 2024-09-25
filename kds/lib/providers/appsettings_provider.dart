import 'dart:async';
import 'package:flutter/material.dart';

import '../constant/constants.dart';

class AppSettingStateProvider extends ChangeNotifier {
  bool _isHorizontal = false;
  double _fontSize = 14.0;
  double _padding = 1.0;
  int _crossAxisCount = 1;
  int _itemsPerPage = 8;
  String _selectedView = KdsConst.fixedGrid;

  double get fontSize => _fontSize;
  double get padding => _padding;
  int get crossAxisCount => _crossAxisCount;
  int get itemsPerPage => _itemsPerPage;
  bool get isHorizontal => _isHorizontal;
  String get selectedView => _selectedView;

  void initializeSettings(BuildContext context) {
    // Initialize values based on the current screen width
    _fontSize = getTitleFontSize(context);
    _padding = getPadding(context);
    _crossAxisCount = getCrossAxisCount(context);
    notifyListeners(); // Notify listeners to rebuild with updated values
    print('does me??');
  }

  double getTitleFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 18.0; // Laptop
    } else if (width >= 800) {
      return 16.0; // Tablet
    } else {
      return 14.0; // Phone
    }
  }

  double getPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 1.0; // Laptop
    } else if (width >= 800) {
      return 1.0; // Tablet
    } else {
      return 1.0; // Phone
    }
  }

  int getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 4; // Laptop
    } else if (width >= 800) {
      return 2; // Tablet
    } else {
      return 1; // Phone
    }
  }

  void changeFontSize(double fontSize) {
    _fontSize = fontSize;
    notifyListeners();
  }

  void changePadding(double padding) {
    _padding = padding;
    notifyListeners();
  }

  void changeCrossAxisCount(int crossAxisCount) {
    _crossAxisCount = crossAxisCount;
    notifyListeners();
  }

  void changesHorizontal(bool isHorizontal) {
    _isHorizontal = isHorizontal;
    notifyListeners();
  }

  void changeView(String selectedView) {
    _selectedView = selectedView;
    notifyListeners();
  }

  void changeItemsPerPage(int itemsPerPage) {
    _itemsPerPage = itemsPerPage;
    notifyListeners();
  }
}
