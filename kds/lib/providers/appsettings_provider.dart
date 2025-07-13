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
  static const int defaultSelectedStation = 1;
  static const bool defaultIsBigButton = true;
  static const double defaultAppBarLogoSize = 80;
  static const int defaultStoreId = 1;

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
  int _selectedStation = defaultSelectedStation;
  bool _isBigButton = defaultIsBigButton;
  double _appBarLogoSize = defaultAppBarLogoSize;
  int _storeId = defaultStoreId;

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
      // Consider implementing a more robust error handling strategy here
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
    _selectedStation =
        _box.get('selectedStation', defaultValue: defaultSelectedStation);
    _isBigButton = _box.get('isBigButton', defaultValue: isBigButton);
    _appBarLogoSize =
        _box.get('appBarLogoSize', defaultValue: defaultAppBarLogoSize);
    _storeId = _box.get('storeId', defaultValue: defaultStoreId);
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
  int get selectedStation => _selectedStation;
  bool get isBigButton => _isBigButton;
  double get appBarLogoSize => _appBarLogoSize;
  int get storeId => _storeId;

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _initHive();
    }
  }

  Future<void> initializeSettings(BuildContext context) async {
    await ensureInitialized();
    bool shouldNotify = false;

    if (!_box.containsKey('fontSize')) {
      _fontSize = _getResponsiveFontSize(context);
      shouldNotify = true;
    }
    if (!_box.containsKey('padding')) {
      _padding = defaultPadding;
      shouldNotify = true;
    }
    if (!_box.containsKey('crossAxisCount')) {
      _crossAxisCount = _getResponsiveCrossAxisCount(context);
      shouldNotify = true;
    }

    if (shouldNotify) {
      await _saveSettings();
      notifyListeners();
    }
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
        'selectedStation': _selectedStation,
        'isBigButton': _isBigButton,
        'appBarLogoSize': _appBarLogoSize,
        'storeId': _storeId,
      });
    } catch (e) {
      debugPrint('Error saving settings: $e');
      // Consider implementing a more robust error handling strategy here
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
        case 'selectedStation':
          _selectedStation = value as int;
          break;
        case 'isBigButton':
          _isBigButton = value as bool;
          break;
        case 'appBarLogoSize':
          _appBarLogoSize = value as double;
          break;
        case 'storeId':
          _storeId = value as int;
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
  Future<void> changeSelectedStation(int selectedStation) =>
      updateSetting('selectedStation', selectedStation);
  Future<void> changeButtonStyle(bool buttonStyle) =>
      updateSetting('isBigButton', buttonStyle);
  Future<void> changeAppBarLogoSize(double logoSize) =>
      updateSetting('appBarLogoSize', logoSize);
  Future<void> changeStoreId(int storeId) => updateSetting('storeId', storeId);
}
