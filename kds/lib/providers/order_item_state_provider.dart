import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:kds/providers/items_details_provider.dart';

class OrderItemStateProvider extends ChangeNotifier {
  final Map<String, OrderItemState> _states = {};
  final KDSItemsProvider kdsItemsProvider;

  OrderItemStateProvider({required this.kdsItemsProvider});

  // Get state for a particular itemId, create a new state if it doesn't exist
  OrderItemState getState(String itemId) {
    return _states[itemId] ?? OrderItemState();
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
  }) async {
    try {
      await kdsItemsProvider.updateItemsInfo(
        storeId: storeId,
        orderId: orderId,
        itemId: itemId,
        isDone: isDone,
        isInProgress: isInProgress,
      );
      notifyListeners();
    } catch (e) {
      // Handle errors (e.g., show a message to the user)
      debugPrint('Failed to update item info: $e');
    }
  }
}

class OrderItemState {
  String buttonText = 'Start';
  bool isButtonVisible = true;
  int countdown = 0;
  Timer? _timer;

  // Method to handle process start and switch button text
  Future<void> handleStartProcess({
    required OrderItemStateProvider provider,
    required String itemId,
    required int storeId,
    required String orderId,
  }) async {
    if (buttonText == 'Start') {
      buttonText = 'Done';

      // Call the async method to update items info and wait for completion
      await _updateItemInfoAndNotify(
        provider: provider,
        itemId: itemId,
        storeId: storeId,
        orderId: orderId,
        isDone: false,
        isInProgress: true,
      );
    } else if (buttonText == 'Done') {
      _startCountdown(provider, itemId, storeId, orderId);
    }
  }

  // Method to update item info and notify listeners
  Future<void> _updateItemInfoAndNotify({
    required OrderItemStateProvider provider,
    required String itemId,
    required int storeId,
    required String orderId,
    required bool isDone,
    required bool isInProgress,
  }) async {
    try {
      await provider.handleUpdateItemsInfo(
        itemId: itemId,
        storeId: storeId,
        orderId: orderId,
        isDone: isDone,
        isInProgress: isInProgress,
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
    );
  }
}
