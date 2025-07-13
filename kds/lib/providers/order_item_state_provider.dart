import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kds/providers/items_details_provider.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../constant/constants.dart';

class OrderItemStateProvider extends ChangeNotifier {
  final Map<String, OrderItemState> _states = {};
  final KDSItemsProvider kdsItemsProvider;
  String _updateError = '';
  HubConnectionState _hubState = HubConnectionState.Disconnected;

  OrderItemStateProvider({required this.kdsItemsProvider});
  HubConnection? _hubConnection;
  HubConnection? get hubConnection => _hubConnection;
  String get updateError => _updateError;
  HubConnectionState get hubState => _hubState;

  // Get state for a particular itemId, create a new state if it doesn't exist
  OrderItemState getState({
    required String itemId,
    required bool isInProgress,
    required bool isDone,
    required bool isReadyToPickup,
    required bool isDelivered,
    // required bool isCompleted,
  }) {
    return _states[itemId] ??
        OrderItemState(
          isInProgress: isInProgress,
          isDone: isDone,
          isReadyToPickup: isReadyToPickup,
          isDelivered: isDelivered,
          // isCompleted: isCompleted
        );
  }

  Map<String, bool> _isButtonDisabled = {};

  bool isButtonDisabled(String itemId) {
    return _isButtonDisabled[itemId] ?? false;
  }

  Future<void> connectSignalR(HubConnection connection) async {
    _hubConnection = connection;
    notifyListeners();
  }

  void setButtonDisabled(String itemId, bool disabled) {
    _isButtonDisabled[itemId] = disabled;
    notifyListeners();
  }

  void resetState(String itemId) {
    if (_states.containsKey(itemId)) {
      _states[itemId] = OrderItemState(
        isInProgress: false,
        isDone: false,
        isReadyToPickup: false,
        isDelivered: false,
        // isCompleted: false
      ); // Reset to default state
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Update state for a specific itemId
  void updateState(String itemId, OrderItemState state) {
    _states[itemId] = state;
    notifyListeners();
  }

  // Trigger `updateItemsInfo` when the countdown or process is done
  Future<void> handleUpdateItemsInfo({
    required String itemId,
    required int storeId,
    required String orderId,
    required bool isDone,
    required bool isInProgress,
    required bool isCompleted,
    required bool isReadyToPickup,
    required bool isDelivered,
  }) async {
    try {
      setButtonDisabled('$itemId-$orderId', true);
      await kdsItemsProvider.updateItemsInfo(
        storeId: storeId,
        orderId: orderId,
        itemId: itemId,
        isDone: isDone,
        isInProgress: isInProgress,
        isCompleted: isCompleted,
        isDelivered: isDelivered,
        isReadyToPickup: isReadyToPickup,
      );

      _updateError = kdsItemsProvider.updateItemError;

      setButtonDisabled('$itemId-$orderId', false);
      checkForHubConnection();
      _hubConnection?.invoke(KdsConst.updateOrderEvent, args: ['1', orderId]);

      notifyListeners();
    } catch (e) {
      // Handle errors (e.g., show a message to the user)
      debugPrint('Failed to update item info: $e');
    }
  }

  void checkForHubConnection() {
    // kdsItemsProvider.emptyUpdateItem();
    _hubState = _hubConnection?.state ?? HubConnectionState.Disconnected;
    notifyListeners();
  }

  void addHubConnection(HubConnectionState hubConnectionState) {
    // kdsItemsProvider.emptyUpdateItem();
    _hubState = hubConnectionState;
    notifyListeners();
  }

  void emptyUpdateErrorMassage() {
    kdsItemsProvider.emptyUpdateItemError();
    notifyListeners();
  }

  Future<void> sandInjury(
      {required String orderId, required String orderTitle}) async {
    try {
      checkForHubConnection();
      _hubConnection
          ?.invoke(KdsConst.inquireOrder, args: ['1', orderId, orderTitle]);
    } catch (e) {
      debugPrint('Failed to send inqury: $e');
    }
  }
}

class OrderItemState {
  OrderItemState({
    required this.isInProgress,
    required this.isDone,
    required this.isReadyToPickup,
    required this.isDelivered,
    // required this.isCompleted,
  });
  String buttonText = 'Start';
  String completeButtonText = 'Not Started';
  bool isButtonVisible = true;
  int countdown = 0;
  Timer? _timer;

  Color buttonColor = KdsConst.grey;
  Color completeButtonColor = KdsConst.black;

  //item State
  bool isInProgress;
  bool isDone;
  bool isReadyToPickup;
  bool isDelivered;
  // bool isCompleted;

  // Method to handle process start and switch button text
  Future<void> handleStartProcess({
    required OrderItemStateProvider provider,
    required String itemId,
    required int storeId,
    required String orderId,
  }) async {
    if (buttonText == 'Start') {
      buttonText = 'Done';
      completeButtonText = 'In Progress';
      buttonColor = KdsConst.green;
      completeButtonColor = KdsConst.orange;
      isInProgress = true;
      isDone = false;
      isReadyToPickup = false;
      isDelivered = false;
      // isCompleted = false;

      // Call the async method to update items info and wait for completion
      await _updateItemInfoAndNotify(
        provider: provider,
        itemId: itemId,
        storeId: storeId,
        orderId: orderId,
        isDone: false,
        isInProgress: true,
        isCompleted: false,
        isReadyToPickup: false,
        isDelivered: false,
      );
    } else if (buttonText == 'Done') {
      _startCountdown(provider, itemId, storeId, orderId);
    }
  }

  Future<void> handleInProcess({
    required OrderItemStateProvider provider,
    required String itemId,
    required int storeId,
    required String orderId,
  }) async {
    _startCountdown(provider, itemId, storeId, orderId);
  }

  Future<void> handleCompleteProcess(
      {required OrderItemStateProvider provider,
      required String itemId,
      required int storeId,
      required String orderId,
      required bool isDineIn}) async {
    // if (buttonText == 'Done') {
    //   buttonText = 'Start';
    //   _completeCountdown(provider, itemId, storeId, orderId);
    // }
    completeButtonText = 'Completed';
    isInProgress = false;
    isDone = false;
    isReadyToPickup = false;
    isDelivered = false;
    // isCompleted = true;
    await _updateItemInfoAndNotify(
      provider: provider,
      itemId: itemId,
      storeId: storeId,
      orderId: orderId,
      isDone: false,
      isInProgress: false,
      isCompleted: true,
      isReadyToPickup: false,
      isDelivered: false,
    );
  }

  Future<void> handleUndoProcess({
    required OrderItemStateProvider provider,
    required String itemId,
    required int storeId,
    required String orderId,
  }) async {
    isInProgress = false;
    isDone = false;
    isReadyToPickup = false;
    isDelivered = false;
    // isCompleted = false;
    await _updateItemInfoAndNotify(
      provider: provider,
      itemId: itemId,
      storeId: storeId,
      orderId: orderId,
      isDone: false,
      isInProgress: false,
      isCompleted: false,
      isReadyToPickup: false,
      isDelivered: false,
    );

    provider.resetState('$itemId-$orderId');
  }

  Future<void> handleDineInDeliverProcess({
    required OrderItemStateProvider provider,
    required String itemId,
    required int storeId,
    required String orderId,
  }) async {
    isInProgress = false;
    isDone = false;
    isReadyToPickup = false;
    isDelivered = true;
    // isCompleted = false;
    await _updateItemInfoAndNotify(
      provider: provider,
      itemId: itemId,
      storeId: storeId,
      orderId: orderId,
      isDone: false,
      isInProgress: false,
      isCompleted: false,
      isReadyToPickup: false,
      isDelivered: true,
    );
  }

  // Method to update item info and notify listeners
  Future<void> _updateItemInfoAndNotify({
    required OrderItemStateProvider provider,
    required String itemId,
    required int storeId,
    required String orderId,
    required bool isDone,
    required bool isInProgress,
    required bool isCompleted,
    required bool isReadyToPickup,
    required bool isDelivered,
  }) async {
    try {
      await provider.handleUpdateItemsInfo(
        itemId: itemId,
        storeId: storeId,
        orderId: orderId,
        isDone: isDone,
        isInProgress: isInProgress,
        isCompleted: isCompleted,
        isReadyToPickup: isReadyToPickup,
        isDelivered: isDelivered,
      );
      provider.notifyListeners();
    } catch (e) {
      // Handle errors
      debugPrint('Failed to update item info: $e');
    }
  }

  // Method to start the countdown and update item info when countdown completes
  void _startCountdown(OrderItemStateProvider provider, String itemId,
      int storeId, String orderId) {
    countdown = 10; // Start countdown from 10 seconds
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (countdown > 0) {
        countdown--;
        provider.notifyListeners(); // Update UI on each tick
      } else {
        timer.cancel();
        _completeCountdown(provider, itemId, storeId, orderId);
      }
    });
  }

  // Method to handle actions after countdown completes
  Future<void> _completeCountdown(OrderItemStateProvider provider,
      String itemId, int storeId, String orderId) async {
    isButtonVisible = false; // Hide button after countdown ends
    await _updateItemInfoAndNotify(
      provider: provider,
      itemId: itemId,
      storeId: storeId,
      orderId: orderId,
      isDone: true,
      isInProgress: false,
      isCompleted: false,
      isReadyToPickup: false,
      isDelivered: false,
    );
    isInProgress = false;
    isDone = true;
    isReadyToPickup = false;
    isDelivered = false;
    // isCompleted = false;
  }
}
