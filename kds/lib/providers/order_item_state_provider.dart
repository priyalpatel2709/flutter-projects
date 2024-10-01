import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kds/providers/items_details_provider.dart';

import '../constant/constants.dart';

class OrderItemStateProvider extends ChangeNotifier {
  final Map<String, OrderItemState> _states = {};
  final KDSItemsProvider kdsItemsProvider;
  String _updateError = '';

  OrderItemStateProvider({required this.kdsItemsProvider});

  // Get state for a particular itemId, create a new state if it doesn't exist
  OrderItemState getState(String itemId) {
    return _states[itemId] ?? OrderItemState();
  }

  void resetState(String itemId) {
    if (_states.containsKey(itemId)) {
      _states[itemId] = OrderItemState(); // Reset to default state
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Update state for a specific itemId
  void updateState(String itemId, OrderItemState state) {
    _states[itemId] = state;
    notifyListeners();
  }

  String get updateError => _updateError;

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

      notifyListeners();
    } catch (e) {
      // Handle errors (e.g., show a message to the user)
      debugPrint('Failed to update item info: $e');
    }
  }

  void emptyUpdateErrorMassage() {
    kdsItemsProvider.emptyUpdateItemError();
    notifyListeners();
  }
}

class OrderItemState {
  String buttonText = 'Start';
  String completeButtonText = 'Not Started';
  bool isButtonVisible = true;
  int countdown = 0;
  Timer? _timer;

  Color buttonColor = KdsConst.grey;
  Color completeButtonColor = KdsConst.black;

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
  }
}
