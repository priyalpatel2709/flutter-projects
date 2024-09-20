import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  const ItemCartV2({
    Key? key,
    required this.items,
    this.selectedKdsId,
    required this.fontSize,
    required this.padding,
    this.isComplete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse and format `createdOn`
    DateTime createdOnDate =
        DateTime.tryParse(items.createdOn)?.toLocal() ?? DateTime.now();
    String formattedCreatedOn =
        DateFormat('hh:mm a').format(createdOnDate); // Format local time

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(formattedCreatedOn),
            const SizedBox(height: 8),
            if (items.orderNote != null)
              Text(
                items.orderNote!,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              ),
            const Divider(),
            Column(
              children: items.items
                  .map((item) => OrderItem(
                        quantity: item.qty,
                        name: item.itemName ?? '',
                        subInfo: item.modifiers ?? '',
                        uniqueId: '${item.itemId}-${items.orderId}',
                        orderId: items.orderId ?? '',
                        isDone: item.isDone,
                        isInProcess: item.isInprogress,
                        itemId: item.itemId,
                        kdsId: item.kdsId,
                        selectedKdsId: selectedKdsId ?? 0,
                        fontSize: fontSize,
                        isComplete: isComplete,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the top section of the order (header) with order type and time
  Widget _buildOrderHeader(String formattedCreatedOn) {
    return Container(
      color: _getOrderTypeColor(items.orderType),
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
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize),
              ),
              const SizedBox(height: 4),
              Text(
                formattedCreatedOn,
                style: TextStyle(color: Colors.black, fontSize: fontSize),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                items.orderTitle,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize),
              ),
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
  final double fontSize;

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
  });

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<OrderItemStateProvider>(context);
    final itemState = stateProvider.getState(uniqueId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Row(
          children: [
            Text(
              '$quantity ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize * 0.8,
                ),
                maxLines: 2, // Allow a maximum of 2 lines
                overflow: TextOverflow
                    .ellipsis, // Add ellipsis after the second line if text overflows
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            subInfo,
            style: TextStyle(
                fontStyle: FontStyle.italic, fontSize: fontSize * 0.8),
          ),
        ),
        trailing: _buildActionButton(itemState, stateProvider),
      ),
    );
  }

  // Build the action button based on item state (start process, complete, etc.)
  Widget _buildActionButton(itemState, OrderItemStateProvider stateProvider) {
    if (isDone) {
      return isComplete
          ? ElevatedButton(
              style: _smallButtonStyle(),
              onPressed: () {
                itemState.handleCompleteProcess(
                    provider: stateProvider,
                    itemId: itemId,
                    storeId: KdsConst.storeId,
                    orderId: orderId);
              },
              child: Text('Complete',
                  style:
                      TextStyle(color: Colors.black, fontSize: fontSize * .8)),
            )
          : const Icon(Icons.check_circle, color: Colors.green);
    } else {
      return isComplete
          ? Text(itemState.completeButtonText,
              style: TextStyle(color: Colors.black, fontSize: fontSize * .8))
          : ElevatedButton(
              style: _smallButtonStyle(),
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
                style: TextStyle(color: Colors.black, fontSize: fontSize * .8),
              ),
            );
    }
  }

  // Button style to maintain consistency in size and padding
  ButtonStyle _smallButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      minimumSize: const Size(50, 30), // Small button size
    );
  }
}
