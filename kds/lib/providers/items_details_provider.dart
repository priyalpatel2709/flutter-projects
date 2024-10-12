import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:signalr_netcore/signalr_client.dart';

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
  List<GroupedOrder> _scheduleGroupedItems = [];
  List<StationsDetails> _stations = [];
  String _itemsError = '';
  String _stationsError = '';
  String _updateItemError = '';
  Timer? _timer;
  int _selectedStation = 0;
  // HubConnection? _hubConnection;
  String _stationFilter = KdsConst.defaultFilter;
  String _expoFilter = KdsConst.defaultFilter;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  List<ItemsDetails> _filteredItems = [];

  // final Map<FilterType, dynamic> _filters = {};

  // Getters
  List<ItemsDetails> get items => _items;
  List<GroupedOrder> get groupedItems => _groupedItems;
  List<GroupedOrder> get scheduleGroupedItems => _scheduleGroupedItems;
  List<StationsDetails> get stations => _stations;
  String get itemsError => _itemsError;
  String get stationsError => _stationsError;
  String get stationFilter => _stationFilter;
  String get expoFilter => _expoFilter;
  String get updateItemError => _updateItemError;
  // HubConnection? get hubConnection => _hubConnection;
  List<ItemsDetails> get filteredItems => _filteredItems;

  late StreamSubscription<List<GroupedOrder>> itemSubscription;
  StreamController<List<GroupedOrder>>? itemListStream;

  void test() {
    itemListStream = StreamController<List<GroupedOrder>>.broadcast();
    itemSubscription =
        itemListStream!.stream.listen((List<GroupedOrder> resource) {
      _groupedItems = resource;
      notifyListeners();
    });
  }

  // Future<void> connectSignalR(HubConnection connection) async {
  //   _hubConnection = connection;
  //   _isConnected = true;
  //   notifyListeners();
  // }
  // Future<void> ensureConnected() async {
  //   if (_hubConnection == null ||
  //       _hubConnection!.state != HubConnectionState.Connected) {
  //     await _reconnect();
  //   }
  // }
  // Future<void> _reconnect() async {
  //   log('Attempting to reconnect to SignalR...');
  //   try {
  //     // await _hubConnection?.start();
  //     _isConnected = true;
  //     log('Successfully reconnected to SignalR');
  //   } catch (e) {
  //     _isConnected = false;
  //     log('Failed to reconnect to SignalR: $e');
  //   }
  //   notifyListeners();
  // }
  // Future<void> invokeSignalR(String methodName, List<Object> args) async {
  //   log('_hubConnection.state ==>${_hubConnection?.state}');
  //   await ensureConnected();
  //   if (_isConnected) {
  //     try {
  //       // await _hubConnection?.invoke(KdsConst.joinGroup, args: ['1']);
  //       log('_hubConnection.state 2==>${_hubConnection?.state}');
  //       _hubConnection?.invoke(KdsConst.joinGroup, args: ['1']);
  //       final result = await _hubConnection?.invoke(methodName, args: args);
  //       log('Invoked SignalR method: $methodName $result');
  //     } catch (e) {
  //       log('Error invoking SignalR method: $e');
  //       rethrow;
  //     }
  //   } else {
  //     throw Exception('SignalR connection is not available');
  //   }
  // }
  // void setConnectionStatus(bool status) {
  //   _isConnected = status;
  //   notifyListeners();
  // }

  // Fetch ItemsDetails data
  final Dio _dio = Dio();

  Future<void> fetchKDSItems({required int storeId}) async {
    await _fetchData(
      '${KdsConst.apiUrl}${KdsConst.getKDSItems}/$storeId',
      (data) => _processKDSItems(data as List<dynamic>),
      'Fetching KDS Items...',
    );
  }

  Future<void> getNewItem({required String orderId}) async {
    await _fetchData(
      '${KdsConst.apiUrl}${KdsConst.getKDSOrder}/$orderId',
      (data) => _processNewItem(data as Map<String, dynamic>),
      'Fetching KDS Items... $orderId',
    );
  }

  Future<void> getScheduleOrder({required String storeId}) async {
    await _fetchData(
      '${KdsConst.apiUrl}${KdsConst.getKDSItemsSchedule}/$storeId',
      (data) {
        // Assuming the data is a List and can be mapped to GroupedOrder
        // log('scheduleOrders ${jsonEncode(data)}');
        List<GroupedOrder> scheduleOrders =
            (data as List).map((item) => GroupedOrder.fromJson(item)).toList();

        // Add the scheduleOrders to your order list
        scheduleGroupedItems
            .addAll(scheduleOrders); // Assuming `order` is a List<GroupedOrder>

        return scheduleOrders;
      },
      'Fetching Schedule KDS Items... $storeId',
    );
  }

  Future<void> _fetchData(
      String url, Function(dynamic) processData, String debugMessage) async {
    if (kDebugMode) {
      print(debugMessage);
      print('URL ... $url');
    }

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        processData(response.data);
        _itemsError = '';
      } else {
        _handleErrorResponse(response.statusCode ?? 400);
      }
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      _handleGeneralException(e);
    }

    notifyListeners();
  }

  void _processKDSItems(List<dynamic> data) {
    Map<String, List<Map<String, dynamic>>> grouped =
        _groupItemsByOrderId(data);
    _groupedItems = _convertToGroupedOrders(grouped);
    addItemsToListStream(_groupedItems);
  }

  void _processNewItem(Map<String, dynamic> data) {
    GroupedOrder newOrder = _createGroupedOrder(data);
    _updateGroupedItems(newOrder);
    addItemsToListStream(_groupedItems);
  }

  Map<String, List<Map<String, dynamic>>> _groupItemsByOrderId(
      List<dynamic> data) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in data) {
      String orderId = item['orderId'];
      grouped.putIfAbsent(orderId, () => []).add(item);
    }
    return grouped;
  }

  List<GroupedOrder> _convertToGroupedOrders(
      Map<String, List<Map<String, dynamic>>> grouped) {
    return grouped.entries.map((entry) {
      var orderItems = entry.value;
      var firstOrder = orderItems.first;
      List<OrderItemModel> items =
          orderItems.map((item) => OrderItemModel.fromJson(item)).toList();

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
        isAllInProgress: items.every((item) => item.isInProgress),
        isAllDone: items.every((item) => item.isDone),
        isAllCancel: items.every((item) => item.isCancel),
        isAnyInProgress: items.any((item) => item.isInProgress),
        isAnyDone: items.any((item) => item.isDone),
        isNewOrder: _checkNewOrder(items, firstOrder['ordertype']),
        deliveredOn: firstOrder['deliveredOn'],
        isAllDelivered: items.every((item) => item.isDelivered),
        isAnyDelivered: items.any((item) => item.isDelivered),
        isDelivered: firstOrder['isDelivered'],
        isReadyToPickup: firstOrder['isReadyToPickup'],
        readyToPickupOn: firstOrder['readyToPickupOn'],
        isDineIn: firstOrder['ordertype'] == KdsConst.dineIn,
      );
    }).toList();
  }

  bool _checkNewOrder(List<OrderItemModel> items, String orderType) {
    return items.every((item) =>
        !item.isInProgress &&
        !item.isDone &&
        (orderType == KdsConst.dineIn
            ? !item.isDelivered
            : !item.isReadyToPickup));
  }

  GroupedOrder _createGroupedOrder(Map<String, dynamic> data) {
    List<OrderItemModel> items = (data['items'] as List<dynamic>)
        .map((item) => OrderItemModel(
              itemId: item['itemId'] ?? '',
              itemName: item['itemName'] ?? '',
              qty: item['quantity'] ?? 0,
              modifiers: item['modifiers'] ?? '',
              isInProgress: item['isInprogress'] ?? false,
              isDone: item['isDone'] ?? false,
              isCancel: item['isCancelled'] ?? false,
              kdsId: item['kdsId'] ?? 0,
              isReadyToPickup: item['isReadyToPickup'] ?? false,
              readyToPickupOn: item['readyToPickupOn'] ?? '',
              isDelivered: item['isDelivered'] ?? false,
              deliveredOn: item['deliveredOn'] ?? '',
            ))
        .toList();

    return GroupedOrder(
      id: data['id'] ?? 0,
      kdsId: 1,
      orderId: data['orderId'] ?? '',
      orderTitle: data['orderTitle'] ?? '',
      orderType: data['orderType'] ?? '',
      orderNote: data['orderNote'] ?? '',
      createdOn: data['createdOn'] ?? '',
      storeId: data['storeId'] ?? 0,
      tableName: '',
      dPartner: data['deliveryPartner'] ?? '',
      displayOrderType: data['displayOrderType'] ?? '',
      items: items,
      isAllInProgress: items.every((item) => item.isInProgress),
      isAllDone: items.every((item) => item.isDone),
      isAllCancel: items.every((item) => item.isCancel),
      isAnyInProgress: items.any((item) => item.isInProgress),
      isAnyDone: items.any((item) => item.isDone),
      isNewOrder: _checkNewOrder(items, data['orderType'] ?? ''),
      deliveredOn: data['deliveredOn'] ?? '',
      isAllDelivered: items.every((item) => item.isDelivered),
      isAnyDelivered: items.any((item) => item.isDelivered),
      isDelivered: data['isDelivered'] ?? false,
      isReadyToPickup: data['isReadyToPickup'] ?? false,
      readyToPickupOn: data['readyToPickupOn'] ?? '',
      isDineIn: data['orderType'] == KdsConst.dineIn,
    );
  }

  void _updateGroupedItems(GroupedOrder newOrder) {
    int existingOrderIndex =
        _groupedItems.indexWhere((order) => order.orderId == newOrder.orderId);
    if (existingOrderIndex != -1) {
      _groupedItems[existingOrderIndex] = newOrder;
    } else {
      _groupedItems.add(newOrder);
    }
  }

  void _handleErrorResponse(int statusCode) {
    _itemsError = 'Failed to load items: $statusCode';
    log(_itemsError);
  }

  void _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      _itemsError = 'The request timed out. Please try again later.';
    } else if (e.type == DioExceptionType.unknown &&
        e.error is SocketException) {
      _itemsError = 'No internet connection. Please check your connection.';
    } else if (e.type == DioExceptionType.badResponse) {
      _itemsError = 'Failed to load items: ${e.response?.statusCode}';
    } else {
      _itemsError = 'An unexpected error occurred: ${e.message}';
    }
  }

  void _handleGeneralException(dynamic e) {
    _itemsError = 'An unexpected error occurred. Please try again later.';
    log('Error: $e');
  }

  void addItemsToListStream(List<GroupedOrder> groupedOrders) {
    itemListStream?.add(groupedOrders);
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

      log('Update Body: ${jsonEncode(requestBody)}');

      if (response.statusCode == 200) {
        log('Update successful: ${response.body}');
        // fetchKDSItems(storeId: storeId).then((_) {
        //   // This will run after fetchKDSItems completes'
        //   notifyListeners();
        // });
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
    // _timer = Timer.periodic(Duration(seconds: timerInterval), (timer) async {
    //   await Future.wait([
    //     fetchKDSItems(storeId: storeId),
    //     // fetchKDSStations(storeId: storeId),
    //   ]);
    // });

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
    itemListStream?.close();
    itemSubscription.cancel();
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
