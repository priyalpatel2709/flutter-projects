import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import '../models/iItems_details_model.dart';
import '../models/stations_details_model.dart';

class KDSItemsProvider with ChangeNotifier {
  List<ItemsDetails> _items = [];
  List<StationsDetails> _stations = [];
  String _itemsError = '';
  String _stationsError = '';
  Timer? _timer;
  int _selectedStation = 0;
  List<ItemsDetails> _filteredItems = [];

  List<ItemsDetails> get items => _items;
  List<StationsDetails> get stations => _stations;
  String get itemsError => _itemsError;
  String get stationsError => _stationsError;
  int get selectedStation => _selectedStation;
  List<ItemsDetails> get filteredItems => _filteredItems;

  // Fetch ItemsDetails data
  Future<void> fetchKDSItems({required int storeId}) async {
    final url = Uri.parse(
        'https://storesposapi.azurewebsites.net/api/GetKDSItemsdetails/$storeId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _items = data.map((item) => ItemsDetails.fromJson(item)).toList();
        _itemsError = '';
        // Apply filter after fetching
        _applyFilter();
      } else {
        _itemsError = 'Failed to load items data: ${response.statusCode}';
      }
    } catch (e) {
      _itemsError = 'Error fetching items: $e';
    }

    notifyListeners();
  }

  // Fetch StationsDetails data
  Future<void> fetchKDSStations({required int storeId}) async {
    final url = Uri.parse(
        'https://storesposapi.azurewebsites.net/api/GetKDSStationsdetails/$storeId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _stations =
            data.map((station) => StationsDetails.fromJson(station)).toList();
        _stationsError = '';
      } else {
        _stationsError = 'Failed to load stations data: ${response.statusCode}';
      }
    } catch (e) {
      _stationsError = 'Error fetching stations: $e';
    }

    notifyListeners();
  }

  // Filter ItemsDetails based on selected kdsId from StationsDetails
  List<ItemsDetails> filterItemsByKdsId(int kdsId) {
    return _items.where((item) => item.kdsId == kdsId).toList();
  }

  // Start a timer to fetch both items and stations periodically
  void startFetching({required int timerInterval, required int storeId}) {
    fetchKDSItems(storeId: storeId);
    fetchKDSStations(storeId: storeId); // Fetch immediately

    _timer = Timer.periodic(Duration(seconds: timerInterval), (_) {
      fetchKDSItems(storeId: storeId);
      fetchKDSStations(storeId: storeId);
    });
  }

  // Stop fetching and cancel the timer
  void stopFetching() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setSelectedStation(int index) {
    _selectedStation = index;
    notifyListeners();
    _applyFilter(); // Apply filter when station changes
  }

  Future<void> updateItemsInfo({
    required int storeId,
    required String orderId,
    required String itemId,
    required bool isDone,
    required bool isInProgress,
    bool isQueue = false,
  }) async {
    final url = Uri.parse(
        'https://storesposapi.azurewebsites.net/api/UpdateKDSItemstatus');

    // Create the request body
    final requestBody = {
      'storeId': storeId,
      'orderId': orderId,
      'itemId': itemId,
      'isQueue': isQueue,
      'isInprogress': isInProgress,
      'isDone': isDone,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      log(' jsonEncode(requestBody)---${jsonEncode(requestBody)}');
      if (response.statusCode == 200) {
        log('Update successful: ${response.body}');
        _itemsError = ''; // Clear any previous errors
        // Apply filter after updating
        _applyFilter();
      } else {
        log('Update failed: ${response.statusCode}');
        _itemsError =
            'Failed to post data. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _itemsError = 'Error: $e';
    }

    notifyListeners();
  }

  void _applyFilter() {
    // Apply filter based on selected station or other criteria
    _filteredItems = filterItems(
      isQueue: null, // Update with actual filter criteria if needed
      isInprogress: true, // Default filter for demonstration
      isDone: null,
      isCancel: null,
    );
    notifyListeners();
  }

  List<ItemsDetails> filterItems({
    bool? isQueue,
    bool? isInprogress,
    bool? isDone,
    bool? isCancel,
    String? ordertype,
    DateTime? createdOn,
    String? displayOrdertype,
  }) {
    return _items.where((item) {
      final matchesQueue = isQueue == null || item.isQueue == isQueue;
      final matchesInprogress =
          isInprogress == null || item.isInprogress == isInprogress;
      final matchesDone = isDone == null || item.isDone == isDone;
      final matchesCancel = isCancel == null || item.isCancel == isCancel;
      final matchesOrdertype = ordertype == null ||
          item.ordertype?.toLowerCase() == ordertype.toLowerCase();
      final matchesCreatedOn =
          createdOn == null || item.createdOn == createdOn.toString();
      final matchesDisplayOrdertype = displayOrdertype == null ||
          item.displayOrdertype?.toLowerCase() ==
              displayOrdertype.toLowerCase();

      return matchesQueue &&
          matchesInprogress &&
          matchesDone &&
          matchesCancel &&
          matchesOrdertype &&
          matchesCreatedOn &&
          matchesDisplayOrdertype;
    }).toList();
  }
}
