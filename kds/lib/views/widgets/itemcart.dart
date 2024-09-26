import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:kds/models/iItems_details_model.dart';
import 'package:provider/provider.dart';

import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/order_item_state_provider.dart';

class ItemCartV2 extends StatelessWidget {
  final GroupedOrder items;
  final int? selectedKdsId;
  final double fontSize;
  final double padding;
  final bool isComplete;
  final String selectedView;

  const ItemCartV2({
    Key? key,
    required this.items,
    this.selectedKdsId,
    required this.fontSize,
    required this.padding,
    this.isComplete = false,
    required this.selectedView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse and format `createdOn`
    DateTime createdOnDate =
        DateTime.tryParse(items.createdOn)?.toLocal() ?? DateTime.now();
    String formattedCreatedOn =
        DateFormat('hh:mm a').format(createdOnDate); // Format local time

    return Card(
      color: Colors.white,
      elevation: 3,
      // margin: EdgeInsets.all(padding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        // side: const BorderSide(color: KdsConst.black, width: .5),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(
                formattedCreatedOn, items.orderId, context, isComplete),
            const SizedBox(height: 4),
            Text(
              items.orderNote,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: items.items
                  .map((item) => OrderItem(
                      quantity: item.qty,
                      name: item.itemName,
                      subInfo: item.modifiers,
                      uniqueId: '${item.itemId}-${items.orderId}',
                      orderId: items.orderId,
                      isDone: item.isDone,
                      isInProcess: item.isInprogress,
                      itemId: item.itemId,
                      kdsId: item.kdsId,
                      selectedKdsId: selectedKdsId ?? 0,
                      fontSize: fontSize,
                      isComplete: isComplete,
                      itemIsComplete: item.isComplete,
                      padding: padding))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the top section of the order (header) with order type and time
  Widget _buildOrderHeader(String formattedCreatedOn, String orderId,
      BuildContext context, bool isComplete) {
    final stateProvider1 = Provider.of<OrderItemStateProvider>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: _getOrderTypeColor(items.orderType),
        border: Border.all(color: KdsConst.black, width: .5),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                items.orderType,
                style: TextStyle(
                    color: KdsConst.black,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize),
              ),
              // const SizedBox(height: 4),
              Text(
                formattedCreatedOn,
                style: TextStyle(color: KdsConst.black, fontSize: fontSize),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                items.orderTitle,
                style: TextStyle(
                    color: KdsConst.black,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize),
              ),
              ElevatedButton(
                style: _smallButtonStyle(KdsConst.onMainColor),
                onPressed: () {
                  stateProvider1.handleUpdateItemsInfo(
                      itemId: '',
                      storeId: KdsConst.storeId,
                      orderId: orderId,
                      isDone: isComplete ? false : true,
                      isInProgress: false,
                      isCompleted: isComplete ? true : false);
                },
                child: Text(
                  'All ${isComplete ? 'Complete' : 'Done'}',
                  style:
                      TextStyle(color: KdsConst.black, fontSize: fontSize * .5),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Get color based on order type
  Color _getOrderTypeColor(String orderType) {
    switch (orderType) {
      case KdsConst.pickup:
        return Colors.yellow;
      case KdsConst.delivery:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

// Button style to maintain consistency in size and padding
ButtonStyle _smallButtonStyle(buttonColor) {
  return ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(),
    backgroundColor: buttonColor,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    minimumSize: const Size(50, 30), // Small button size
  );
}

class OrderItem extends StatelessWidget {
  final int quantity;
  final int kdsId;
  final int selectedKdsId;
  final String name;
  final String subInfo;
  final String uniqueId;
  final String itemId;
  final String orderId;
  final bool isDone;
  final bool isComplete;
  final bool isInProcess;
  final bool itemIsComplete;
  final double fontSize;
  final double padding;

  const OrderItem({
    super.key,
    required this.quantity,
    required this.name,
    required this.subInfo,
    required this.uniqueId,
    required this.orderId,
    required this.isDone,
    required this.isInProcess,
    required this.itemId,
    required this.kdsId,
    required this.selectedKdsId,
    required this.fontSize,
    required this.isComplete,
    required this.itemIsComplete,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<OrderItemStateProvider>(context);
    final itemState = stateProvider.getState(uniqueId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items vertically
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to start
              children: [
                Row(
                  children: [
                    Text(
                      '$quantity ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: fontSize),
                    ),
                    Expanded(
                      child: Text(
                        // '$name ($kdsId)',
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize * 0.8,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // Handle long text
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: subInfo != '',
                  child: Text(
                    subInfo,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: fontSize * 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(itemState, stateProvider, itemIsComplete, padding
              // stateProvider: stateProvider,
              // itemIsComplete: itemIsComplete,
              // isInprogress: isInProcess,
              // isDone: isDone,
              // isCompleted: isComplete,
              // itemState: itemState
              ),
        ],
      ),
    );
  }

  // Build the action button based on item state (start process, complete, etc.)
  Widget _buildActionButton(itemState, OrderItemStateProvider stateProvider,
      bool itemIsComplete, double padding) {
    if (isDone) {
      return isComplete
          ? Padding(
              padding: EdgeInsets.all(8 + padding),
              child: ElevatedButton(
                style: _smallButtonStyle(KdsConst.onMainColor),
                onPressed: () {
                  itemState.handleCompleteProcess(
                      provider: stateProvider,
                      itemId: itemId,
                      storeId: KdsConst.storeId,
                      orderId: orderId);
                },
                child: Text('Complete',
                    style: TextStyle(
                        color: KdsConst.black, fontSize: fontSize * .8)),
              ),
            )
          : ElevatedButton(
              style: _smallButtonStyle(Colors.amber),
              onPressed: () {
                itemState.handleUndoProcess(
                    provider: stateProvider,
                    itemId: itemId,
                    storeId: KdsConst.storeId,
                    orderId: orderId);
                stateProvider.updateState(uniqueId, itemState);
              },
              child: Text(
                "Undo",
                style:
                    TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
              ),
            );
      // const Icon(Icons.check_circle, color: Colors.red);
    } else {
      return isComplete
          ? itemIsComplete
              ? const Icon(Icons.check_circle, color: Colors.green)
              : Text(itemState.completeButtonText,
                  style: TextStyle(
                      color: itemState.completeButtonColor,
                      fontSize: fontSize * .8))
          : itemIsComplete
              ? const Icon(Icons.check_circle, color: Colors.green)
              : Padding(
                  padding: EdgeInsets.all(8 + padding),
                  child: ElevatedButton(
                    style: _smallButtonStyle(itemState.buttonColor),
                    onPressed: () {
                      itemState.handleStartProcess(
                          provider: stateProvider,
                          itemId: itemId,
                          storeId: KdsConst.storeId,
                          orderId: orderId);
                      stateProvider.updateState(uniqueId, itemState);
                    },
                    child: Text(
                      itemState.countdown > 0
                          ? 'Done (${itemState.countdown})'
                          : itemState.buttonText,
                      style: TextStyle(
                          color: KdsConst.black, fontSize: fontSize * .8),
                    ),
                  ),
                );
    }
  }
}
