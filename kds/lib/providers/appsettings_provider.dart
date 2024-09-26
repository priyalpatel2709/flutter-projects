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
  String _selectedOrderType = KdsConst.dineIn;
  bool _showPagination = false;

  double get fontSize => _fontSize;
  double get padding => _padding;
  int get crossAxisCount => _crossAxisCount;
  int get itemsPerPage => _itemsPerPage;
  bool get isHorizontal => _isHorizontal;
  bool get showPagination => _showPagination;
  String get selectedView => _selectedView;
  String get selectedOrderType => _selectedOrderType;

  void initializeSettings(BuildContext context) {
    // Initialize values based on the current screen width
    _fontSize = getTitleFontSize(context);
    _padding = getPadding(context);
    _crossAxisCount = getCrossAxisCount(context);
    notifyListeners(); // Notify listeners to rebuild with updated values
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

  double getPadding(BuildContext context) =>
      1.0; // No need to calculate based on screen width.

  int getCrossAxisCount(BuildContext context) =>
      MediaQuery.of(context).size.width >= 800
          ? (MediaQuery.of(context).size.width >= 1200 ? 4 : 2)
          : 1;

  void changeFontSize(double fontSize) {
    if (_fontSize != fontSize) {
      _fontSize = fontSize;
      notifyListeners();
    }
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
    if (_selectedView != selectedView) {
      _selectedView = selectedView;
      notifyListeners();
    }
  }

  /// Changes the number of items to show per page in the list/grid/masonry
  /// views and notifies the listeners.
  ///
  /// The [itemsPerPage] argument should be a positive integer.
  void changeItemsPerPage(int itemsPerPage) {
    if (itemsPerPage > 0 && _itemsPerPage != itemsPerPage) {
      _itemsPerPage = itemsPerPage;
      notifyListeners();
    }
  }

  void changeSelectedOrderType(String orderType) {
    _selectedOrderType = orderType;
    notifyListeners();
  }

  void changeShowPagination(bool showPagination) {
    _showPagination = showPagination;
    notifyListeners();
  }
}
