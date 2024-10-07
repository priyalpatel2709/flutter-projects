import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constant/constants.dart';
import '../models/groupedorder_model.dart';
import '../models/iItems_details_model.dart';
import '../models/stations_details_model.dart';

// enum FilterType {
//   isQueue,
//   isInProgress,
//   isDone,
//   isCancel,
//   orderType,
//   createdOn,
//   kdsId,
//   isCompleted
// }

class KDSItemsProvider with ChangeNotifier {
  // KDSItemsProvider();
  List<ItemsDetails> _items = [];
  List<GroupedOrder> _groupedItems = [];
  List<StationsDetails> _stations = [];
  String _itemsError = '';
  String _stationsError = '';
  String _updateItemError = '';
  Timer? _timer;
  int _selectedStation = 0;
  String _stationFilter = KdsConst.defaultFilter;
  String _expoFilter = KdsConst.defaultFilter;

  List<ItemsDetails> _filteredItems = [];

  // final Map<FilterType, dynamic> _filters = {};

  // Getters
  List<ItemsDetails> get items => _items;
  List<GroupedOrder> get groupedItems => _groupedItems;
  List<StationsDetails> get stations => _stations;
  String get itemsError => _itemsError;
  String get stationsError => _stationsError;
  String get stationFilter => _stationFilter;
  String get expoFilter => _expoFilter;
  String get updateItemError => _updateItemError;
  List<ItemsDetails> get filteredItems => _filteredItems;

  late StreamSubscription<List<GroupedOrder>> itemSubscription;
  StreamController<List<GroupedOrder>>? itemListStream;

  void test() {
    itemListStream = StreamController<List<GroupedOrder>>.broadcast();
    itemSubscription =
        itemListStream!.stream.listen((List<GroupedOrder> resource) {
      log('resource==>Does me');
      // updateOffset(resource.data!.length);
      // print(resource.data!.length);
      _groupedItems = resource;

      // if (resource.status != PsStatus.BLOCK_LOADING &&
      //     resource.status != PsStatus.PROGRESS_LOADING) {
      //   isLoading = false;
      // }

      // if (!isDispose) {
      notifyListeners();
      // }
    });
  }

  // Fetch ItemsDetails data
  Future<void> fetchKDSItems({required int storeId}) async {
    final String url = '${KdsConst.apiUrl}${KdsConst.getKDSItems}/$storeId';

    if (kDebugMode) {
      print('Fetching KDS Items...');
    }

    try {
      Dio dio = Dio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;

        // Group items by orderId
        Map<String, List<Map<String, dynamic>>> grouped = {};
        for (var item in data) {
          String orderId = item['orderId'];
          if (!grouped.containsKey(orderId)) {
            grouped[orderId] = [];
          }
          grouped[orderId]!.add(item);
        }

        // Convert the grouped data to GroupedOrder
        List<GroupedOrder> groupedOrders = grouped.entries.map((entry) {
          var orderItems = entry.value;

          // Create the list of OrderItemV2
          List<OrderItemModel> items = orderItems.map((item) {
            return OrderItemModel.fromJson(item);
          }).toList();

          // Check statuses
          bool allInProgress = items.every((item) => item.isInProgress);
          bool allDone = items.every((item) => item.isDone);
          bool allCancel = items.every((item) => item.isCancel);

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
            isAnyInProgress: items.any((item) => item.isInProgress),
            isAnyDone: items.any((item) => item.isDone),
            isNewOrder: items.every((item) => item.isInProgress == false &&
                    item.isDone == false &&
                    firstOrder['ordertype'] == KdsConst.dineIn
                ? item.isDelivered == false
                : item.isReadyToPickup == false),
            deliveredOn: firstOrder['deliveredOn'],
            isAllDelivered: items.every((item) => item.isDelivered),
            isAnyDelivered: items.any((item) => item.isDelivered),
            isDelivered: firstOrder['isDelivered'],
            isReadyToPickup: firstOrder['isReadyToPickup'],
            readyToPickupOn: firstOrder['readyToPickupOn'],
            isDineIn: firstOrder['ordertype'] == KdsConst.dineIn,
          );
        }).toList();

        _groupedItems = groupedOrders;
        itemListStream?.add(groupedOrders);
        _itemsError = '';

        // Reapply filters after fetching
        // _applyFilters();
      } else {
        _itemsError = 'Failed to load items: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        _itemsError = 'The request timed out. Please try again later.';
      } else if (e.type == DioExceptionType.unknown ||
          e.error is SocketException) {
        _itemsError = 'No internet connection. Please check your connection.';
      } else if (e.type == DioExceptionType.badResponse) {
        _itemsError = 'Failed to load items: ${e.response?.statusCode}';
      } else {
        _itemsError = 'An unexpected error occurred: ${e.message}';
      }
    } catch (e) {
      log('Error fetching items: $e');
      _itemsError = 'An unexpected error occurred. Please try again later.';
    }

    notifyListeners();
  }

  // Fetch StationsDetails data
  Future<void> fetchKDSStations({required int storeId}) async {
    final url =
        Uri.parse('${KdsConst.apiUrl}${KdsConst.getKDSStations}/$storeId');
    if (kDebugMode) {
      print('Fetching KDS Stations...');
    }
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
    } on SocketException {
      _stationsError = 'No internet connection. Please check your connection.';
    } on TimeoutException {
      _stationsError = 'The request timed out. Please try again later.';
    } on FormatException {
      _stationsError = 'Received data is in an invalid format.';
    } on HttpException {
      _stationsError = 'HTTP error occurred. Please try again later.';
    } on IOException {
      _stationsError = 'An I/O error occurred. Please try again.';
    } catch (e) {
      log('Error fetching stations: $e');
      _stationsError = 'An unexpected error occurred. Please try again later.';
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
    required bool isDelivered,
    required bool isReadyToPickup,
    bool isQueue = false,
  }) async {
    final url = Uri.parse('${KdsConst.apiUrl}${KdsConst.updateKDSItemStatus}');

    final requestBody = {
      'storeId': storeId,
      'orderId': orderId,
      'itemId': itemId,
      'isInprogress': isInProgress,
      'isDone': isDone,
      'isDelivered': isDelivered,
      'isReadyToPickup': isReadyToPickup
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        log('Update successful: ${response.body}');
        await fetchKDSItems(storeId: storeId);
        _updateItemError = ''; // Clear any previous errors
        // startFetching(timerInterval: 10, storeId: storeId);

        // _applyFilters();
      } else {
        log('Update failed: ${response.body}');
        _updateItemError =
            'Failed to update item status: ${response.statusCode}';
      }
    } on SocketException {
      _updateItemError =
          'No internet connection. Please check your connection.';
    } on TimeoutException {
      _updateItemError = 'The request timed out. Please try again later.';
    } on FormatException {
      _updateItemError = 'Received data is in an invalid format.';
    } on HttpException {
      _updateItemError = 'HTTP error occurred. Please try again later.';
    } on IOException {
      _updateItemError = 'An I/O error occurred. Please try again.';
    } catch (e) {
      log('Error updating items: $e');
      _updateItemError =
          'An unexpected error occurred. Please try again later.';
    }

    notifyListeners();
  }

  // Start a timer to fetch both items and stations periodically
  void startFetching({required int timerInterval, required int storeId}) {
    _timer = Timer.periodic(Duration(seconds: timerInterval), (timer) async {
      await Future.wait([
        fetchKDSItems(storeId: storeId),
        // fetchKDSStations(storeId: storeId),
      ]);
    });

    // Fetch immediately
    fetchKDSItems(storeId: storeId);
    // fetchKDSStations(storeId: storeId);
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
    // updateFilters(kdsId: _stations[index].kdsId);
  }

  // Update filter criteria and apply filters
  // void updateFilters({
  //   bool? isQueue,
  //   bool? isInProgress,
  //   bool? isDone,
  //   bool? isCancel,
  //   String? orderType,
  //   DateTime? createdOn,
  //   int? kdsId,
  // }) {
  //   if (isQueue != null) _filters[FilterType.isQueue] = isQueue;
  //   if (isInProgress != null) _filters[FilterType.isInProgress] = isInProgress;
  //   if (isDone != null) _filters[FilterType.isDone] = isDone;
  //   if (isCancel != null) _filters[FilterType.isCancel] = isCancel;
  //   if (orderType != null) {
  //     _filters[FilterType.orderType] = orderType.toLowerCase();
  //   }
  //   if (createdOn != null) _filters[FilterType.createdOn] = createdOn;
  //   if (kdsId != null) _filters[FilterType.kdsId] = kdsId;

  //   // _applyFilters();
  // }

  // Method to clear all filters
  // void clearFilters() {
  //   _filters.clear();
  //   // _applyFilters();
  // }

  // Method to remove a specific filter
  // void removeFilter(FilterType filterType) {
  //   _filters.remove(filterType);
  //   // _applyFilters();
  // }

  // Method to add a new filter
  // void changeStationFilter(String value) {
  //   _stationFilter = value;
  //   notifyListeners();
  // }

  void changeExpoFilter(String value) {
    _expoFilter = value;
    notifyListeners();
  }

  void emptyUpdateItemError() {
    _updateItemError = '';
    notifyListeners();
  }
}
