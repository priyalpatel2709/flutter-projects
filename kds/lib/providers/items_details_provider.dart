import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constant/constants.dart';
import '../models/groupedorder_model.dart';
import '../models/iItems_details_model.dart';
import '../models/stations_details_model.dart';

enum FilterType {
  isQueue,
  isInProgress,
  isDone,
  isCancel,
  orderType,
  createdOn,
  kdsId,
  isCompleted
}

class KDSItemsProvider with ChangeNotifier {
  List<ItemsDetails> _items = [];
  List<GroupedOrder> _groupedItems = [];
  List<StationsDetails> _stations = [];
  String _itemsError = '';
  String _stationsError = '';
  Timer? _timer;
  int _selectedStation = 0;
  String _stationFilter = KdsConst.defaultFilter;
  String _expoFilter = KdsConst.defaultFilter;

  List<ItemsDetails> _filteredItems = [];

  // Define an enum for filter types

  // Use a map to store filter values
  final Map<FilterType, dynamic> _filters = {};

  // Getters
  List<ItemsDetails> get items => _items;
  List<GroupedOrder> get groupedItems => _groupedItems;
  List<StationsDetails> get stations => _stations;
  String get itemsError => _itemsError;
  String get stationsError => _stationsError;
  String get stationFilter => _stationFilter;
  String get expoFilter => _expoFilter;
  List<ItemsDetails> get filteredItems => _filteredItems;

  // Fetch ItemsDetails data
  Future<void> fetchKDSItems({required int storeId}) async {
    final url = Uri.parse(
        'https://storesposapi.azurewebsites.net/api/GetKDSItemsdetails/$storeId');
    print('items calling');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Step 3: Group the items by orderId
        Map<String, List<Map<String, dynamic>>> grouped = {};
        for (var item in data) {
          String orderId = item['orderId'];
          if (!grouped.containsKey(orderId)) {
            grouped[orderId] = [];
          }
          grouped[orderId]!.add(item);
        }

        // Step 4: Convert the grouped data to the new format
        List<GroupedOrder> groupedOrders = grouped.entries.map((entry) {
          var orderItems = entry.value;

          // Create the list of OrderItemV2
          List<OrderItemV2> items = orderItems.map((item) {
            return OrderItemV2.fromJson(item);
          }).toList();

          // Check if all items have specific statuses
          bool allInProgress = items.every((item) => item.isInprogress);
          bool allDone = items.every((item) => item.isDone);
          bool allCancel = items.every((item) => item.isCancel);

          // Create the GroupedOrder
          var firstOrder = orderItems.first;
          return GroupedOrder(
            id: firstOrder['id'],
            kdsId: firstOrder['kdsId'],
            orderId: firstOrder['orderId'],
            orderTitle: firstOrder['ordertitle'],
            orderType: firstOrder['ordertype'],
            orderNote: firstOrder['orderNote'],
            createdOn: firstOrder['createdOn'],
            storeId: firstOrder['storeId'],
            tableName: firstOrder['tableName'],
            dPartner: firstOrder['dPartner'],
            displayOrderType: firstOrder['displayOrdertype'],
            items: items,
            isAllInProgress: allInProgress,
            isAllDone: allDone,
            isAllCancel: allCancel,
            isAnyInProgress: items.any((item) => item.isInprogress),
            isAnyDone: items.any((item) => item.isDone),
            isAnyComplete: items.any((item) => item.isComplete),
            isAllComplete: items.every((item) => item.isComplete),
          );
        }).toList();

        _groupedItems = groupedOrders;
        _itemsError = '';

        // Reapply filters after fetching
        _applyFilters();
      } else {
        _itemsError = 'Failed to load items data: ${response.statusCode}';
      }
    } catch (e) {
      log('Error fetching items: $e');
      _itemsError = 'Error fetching items: $e';
    }

    notifyListeners();
  }

  // Fetch StationsDetails data
  Future<void> fetchKDSStations({required int storeId}) async {
    final url = Uri.parse(
        'https://storesposapi.azurewebsites.net/api/GetKDSStationsdetails/$storeId');
    print('items calling');
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

  Future<void> updateItemsInfo({
    required int storeId,
    required String orderId,
    required String itemId,
    required bool isDone,
    required bool isInProgress,
    required bool isCompleted,
    bool isQueue = false,
  }) async {
    final url = Uri.parse(
        'https://storesposapi.azurewebsites.net/api/UpdateKDSItemstatus');

    // Create the request body
    final requestBody = {
      'storeId': storeId,
      'orderId': orderId,
      'itemId': itemId,
      // 'isQueue': isQueue,
      'isInprogress': isInProgress,
      'isDone': isDone,
      'IsCompleted': isCompleted
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
        // Apply filters after updating
        startFetching(timerInterval: 10, storeId: storeId);
        _applyFilters();
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

  // Set selected station and reapply filter
  void setSelectedStation(int index) {
    _selectedStation = index;
    updateFilters(kdsId: _stations[index].kdsId);
  }

  // Update filter criteria and apply filters
  void updateFilters({
    bool? isQueue,
    bool? isInProgress,
    bool? isDone,
    bool? isCancel,
    String? orderType,
    DateTime? createdOn,
    int? kdsId,
  }) {
    if (isQueue != null) _filters[FilterType.isQueue] = isQueue;
    if (isInProgress != null) _filters[FilterType.isInProgress] = isInProgress;
    if (isDone != null) _filters[FilterType.isDone] = isDone;
    if (isCancel != null) _filters[FilterType.isCancel] = isCancel;
    if (orderType != null)
      _filters[FilterType.orderType] = orderType.toLowerCase();
    if (createdOn != null) _filters[FilterType.createdOn] = createdOn;
    if (kdsId != null) _filters[FilterType.kdsId] = kdsId;

    _applyFilters();
  }

  // Apply filters to create the filtered list based on current criteria
  void _applyFilters() {
    _filteredItems = _items.where((item) {
      return _filters.entries.every((filter) {
        switch (filter.key) {
          case FilterType.isQueue:
            return item.isQueue == filter.value;
          case FilterType.isInProgress:
            return item.isInprogress == filter.value;
          case FilterType.isDone:
            return item.isDone == filter.value;
          case FilterType.isCancel:
            return item.isCancel == filter.value;
          case FilterType.orderType:
            return item.ordertype?.toLowerCase() == filter.value;
          case FilterType.createdOn:
            return item.createdOn == filter.value.toString();
          case FilterType.kdsId:
            return item.kdsId == filter.value;
          case FilterType.isCompleted:
            return item.isComplete == filter.value;
        }
      });
    }).toList();

    notifyListeners();
  }

  // Method to clear all filters
  void clearFilters() {
    _filters.clear();
    _applyFilters();
  }

  // Method to remove a specific filter
  void removeFilter(FilterType filterType) {
    _filters.remove(filterType);
    _applyFilters();
  }

  // Method to add a new filter
  void changeStationFilter(String value) {
    _stationFilter = value;
    notifyListeners();
  }

  void changeExpoFilter(String value) {
    _expoFilter = value;
    notifyListeners();
  }
}
