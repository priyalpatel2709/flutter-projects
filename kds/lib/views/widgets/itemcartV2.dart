import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kds/models/iItems_details_model.dart';
import 'package:provider/provider.dart';

import '../../models/groupedorder_model.dart';
import '../../providers/order_item_state_provider.dart';

class ItemCartV2 extends StatelessWidget {
  final GroupedOrder items;

  const ItemCartV2({
    Key? key,
    required this.items,
    // required OrderItemStateProvider orderItemStateProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse the `createdOn` field to local time
    DateTime createdOnDate =
        DateTime.tryParse(items.createdOn)?.toLocal() ?? DateTime.now();
    String formattedCreatedOn = DateFormat('yyyy-MM-dd hh:mm a')
        .format(createdOnDate); // Format the local time
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top blue section with Dine-In, time, table, and order number
            Container(
              color: items.orderType == 'Pickup'
                  ? Colors.yellow
                  : items.orderType == 'Delivery'
                      ? Colors.red
                      : Colors.blue,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items.orderType,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedCreatedOn, // Display the formatted local time
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        items.orderTitle,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Order number and client name
            Text(
              items.orderNote ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Order items
            ...items.items
                .map((item) => OrderItem(
                      quantity: item.qty,
                      name: item.itemName ?? '',
                      subInfo: item.modifiers ?? '',
                      uniqueId: '${item.itemId}-${items.orderId}',
                      orderId: items.orderId ?? '',
                      isDone: item.isDone,
                      isInProcess: item.isInprogress,
                      itemId: item.itemId,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final int quantity;
  final String name;
  final String subInfo;
  final String uniqueId;
  final String itemId;
  final String orderId;
  final bool isDone;
  final bool isInProcess;

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
    // required this.orderItemStateProvider, // Pass the unique identifier
  });

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<OrderItemStateProvider>(context);
    final itemState = stateProvider.getState(uniqueId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$quantity ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    subInfo,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          if (!isDone)
            ElevatedButton(
              onPressed: () {
                // Handle button press
                itemState.handleStartProcess(
                    provider: stateProvider,
                    itemId: itemId,
                    storeId: 1,
                    orderId: orderId);
                stateProvider.updateState(uniqueId, itemState);
              },
              child: Text(
                itemState.countdown > 0
                    ? 'Done (${itemState.countdown})'
                    : itemState.buttonText,
                style: const TextStyle(color: Colors.black),
              ),
            )
          else
            const Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
}
