import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constant/constants.dart';

class AppSettingStateProvider extends ChangeNotifier {
  static const String _boxName = 'appSettings';
  late Box<dynamic> _box;
  bool _isInitialized = false;

  // Default values
  static const bool defaultIsHorizontal = false;
  static const double defaultFontSize = 14.0;
  static const double defaultPadding = 1.0;
  static const int defaultCrossAxisCount = 1;
  static const int defaultItemsPerPage = 8;
  static const String defaultSelectedView = KdsConst.fixedGrid;
  static const String defaultSelectedOrderType = KdsConst.dineIn;
  static const bool defaultShowPagination = false;
  static const int defaultSelectedIndexPage = 0;

  // Settings
  bool _isHorizontal = defaultIsHorizontal;
  double _fontSize = defaultFontSize;
  double _padding = defaultPadding;
  int _crossAxisCount = defaultCrossAxisCount;
  int _itemsPerPage = defaultItemsPerPage;
  String _selectedView = defaultSelectedView;
  String _selectedOrderType = defaultSelectedOrderType;
  bool _showPagination = defaultShowPagination;
  int _selectedIndexPage = defaultSelectedIndexPage;

  AppSettingStateProvider() {
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<dynamic>(_boxName);
      await _loadSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      // Handle the error appropriately, maybe set default values
    }
  }

  Future<void> _loadSettings() async {
    _isHorizontal = _box.get('isHorizontal', defaultValue: defaultIsHorizontal);
    _fontSize = _box.get('fontSize', defaultValue: defaultFontSize);
    _padding = _box.get('padding', defaultValue: defaultPadding);
    _crossAxisCount =
        _box.get('crossAxisCount', defaultValue: defaultCrossAxisCount);
    _itemsPerPage = _box.get('itemsPerPage', defaultValue: defaultItemsPerPage);
    _selectedView = _box.get('selectedView', defaultValue: defaultSelectedView);
    _selectedOrderType =
        _box.get('selectedOrderType', defaultValue: defaultSelectedOrderType);
    _showPagination =
        _box.get('showPagination', defaultValue: defaultShowPagination);
    _selectedIndexPage =
        _box.get('selectedIndexPage', defaultValue: defaultSelectedIndexPage);
  }

  // Getters
  bool get isHorizontal => _isHorizontal;
  double get fontSize => _fontSize;
  double get padding => _padding;
  int get crossAxisCount => _crossAxisCount;
  int get itemsPerPage => _itemsPerPage;
  String get selectedView => _selectedView;
  String get selectedOrderType => _selectedOrderType;
  bool get showPagination => _showPagination;
  int get selectedIndexPage => _selectedIndexPage;

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initHive();
    }
  }

  Future<void> initializeSettings(BuildContext context) async {
    await ensureInitialized();
    if (!_box.containsKey('fontSize')) {
      _fontSize = _getResponsiveFontSize(context);
    }
    if (!_box.containsKey('padding')) {
      _padding = defaultPadding;
    }
    if (!_box.containsKey('crossAxisCount')) {
      _crossAxisCount = _getResponsiveCrossAxisCount(context);
    }
    await _saveSettings();
    notifyListeners();
  }

  double _getResponsiveFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 18.0;
    if (width >= 800) return 16.0;
    return defaultFontSize;
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 800) return 2;
    return defaultCrossAxisCount;
  }

  Future<void> _saveSettings() async {
    try {
      await _box.putAll({
        'isHorizontal': _isHorizontal,
        'fontSize': _fontSize,
        'padding': _padding,
        'crossAxisCount': _crossAxisCount,
        'itemsPerPage': _itemsPerPage,
        'selectedView': _selectedView,
        'selectedOrderType': _selectedOrderType,
        'showPagination': _showPagination,
        'selectedIndexPage': _selectedIndexPage,
      });
    } catch (e) {
      debugPrint('Error saving settings: $e');
      // Handle the error appropriately
    }
  }

  Future<void> updateSetting<T>(String key, T value) async {
    await ensureInitialized();
    if (_box.get(key) != value) {
      switch (key) {
        case 'isHorizontal':
          _isHorizontal = value as bool;
          break;
        case 'fontSize':
          _fontSize = value as double;
          break;
        case 'padding':
          _padding = value as double;
          break;
        case 'crossAxisCount':
          _crossAxisCount = value as int;
          break;
        case 'itemsPerPage':
          if (value as int > 0) _itemsPerPage = value;
          break;
        case 'selectedView':
          _selectedView = value as String;
          break;
        case 'selectedOrderType':
          _selectedOrderType = value as String;
          break;
        case 'showPagination':
          _showPagination = value as bool;
          break;
        case 'selectedIndexPage':
          _selectedIndexPage = value as int;
          break;
        default:
          throw ArgumentError('Invalid setting key: $key');
      }
      await _saveSettings();
      notifyListeners();
    }
  }

  // Convenience methods for updating specific settings
  Future<void> changeFontSize(double fontSize) =>
      updateSetting('fontSize', fontSize);
  Future<void> changePadding(double padding) =>
      updateSetting('padding', padding);
  Future<void> changeCrossAxisCount(int crossAxisCount) =>
      updateSetting('crossAxisCount', crossAxisCount);
  Future<void> changeIsHorizontal(bool isHorizontal) =>
      updateSetting('isHorizontal', isHorizontal);
  Future<void> changeView(String selectedView) =>
      updateSetting('selectedView', selectedView);
  Future<void> changeItemsPerPage(int itemsPerPage) =>
      updateSetting('itemsPerPage', itemsPerPage);
  Future<void> changeSelectedOrderType(String orderType) =>
      updateSetting('selectedOrderType', orderType);
  Future<void> changeShowPagination(bool showPagination) =>
      updateSetting('showPagination', showPagination);
  Future<void> changeSelectedIndexPage(int selectedIndexPage) =>
      updateSetting('selectedIndexPage', selectedIndexPage);
}
