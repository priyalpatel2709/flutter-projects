import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/order_item_state_provider.dart';

class ItemCartV2 extends StatelessWidget {
  final GroupedOrder items;
  final int? selectedKdsId;
  final double fontSize;
  final double padding;
  final bool isExpoScreen;
  final String selectedView;

  const ItemCartV2({
    Key? key,
    required this.items,
    this.selectedKdsId,
    required this.fontSize,
    required this.padding,
    this.isExpoScreen = false,
    required this.selectedView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String convertISOtoLocal(String isoTime, String orderTitle) {
      // Parse the ISO 8601 date string
      DateTime dateTime = DateTime.parse(isoTime);

      DateTime pstDateTime = dateTime.toUtc().toLocal();

      // Format the PST date
      String formattedDate = intl.DateFormat('hh:mm a').format(pstDateTime);

      return formattedDate;
    }

    return Consumer<OrderItemStateProvider>(
      builder:
          (BuildContext context, OrderItemStateProvider value, Widget? child) {
        return Padding(
          padding: EdgeInsets.all(padding + 4),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: KdsConst.mainColor, width: .5),
            ),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0)),
              child: Padding(
                padding: EdgeInsets.all(padding + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(
                        context,
                        convertISOtoLocal(
                            '${items.createdOn}Z', items.orderTitle),
                        value),
                    const SizedBox(height: 4),
                    if (items.orderNote.isNotEmpty)
                      Text(
                        items.orderNote,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: fontSize),
                      ),
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.items.length,
                      itemBuilder: (context, index) {
                        return OrderItem(
                          item: items.items[index],
                          orderId: items.orderId,
                          selectedKdsId: selectedKdsId ?? 0,
                          fontSize: fontSize,
                          isExpoScreen: isExpoScreen,
                          padding: padding,
                          isDineIn: items.isDineIn,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderHeader(BuildContext context, String formattedCreatedOn,
      OrderItemStateProvider stateProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        // color: _getOrderTypeColor(items.orderType),
        gradient: LinearGradient(colors: <Color>[
          _getOrderTypeColor(items.orderType),
          Colors.white,
        ]),
        border: Border.all(color: KdsConst.black, width: .5),
      ),
      padding: EdgeInsets.all(1 + padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                items.orderType,
                style: TextStyle(
                  color: KdsConst.black,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
              Text(
                '#${items.orderTitle}',
                style: TextStyle(
                  color: KdsConst.black,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  formattedCreatedOn,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize * 0.8,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildActionButton(context, stateProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, OrderItemStateProvider stateProvider) {
    if (isExpoScreen) {
      if (items.orderType != KdsConst.dineIn && !items.isReadyToPickup) {
        return Padding(
          padding: EdgeInsets.all(padding),
          child: ElevatedButton(
            style: _smallButtonStyle(KdsConst.green),
            onPressed: () => _handleReadyToPickup(stateProvider),
            child: Text(
              'Ready',
              style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
            ),
          ),
        );
      } else {
        return Visibility(
          visible: !items.isAllDelivered && items.isAllDone,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: ElevatedButton(
              style: _smallButtonStyle(KdsConst.green),
              onPressed: () => _handleAllDeliver(stateProvider),
              child: Text(
                'All Deliver',
                style:
                    TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
              ),
            ),
          ),
        );
      }
    } else if (!items.isAllDone && items.isDineIn
        ? !items.isAllDelivered
        : !items.isReadyToPickup) {
      return ElevatedButton(
        style: _smallButtonStyle(KdsConst.darkGreen),
        onPressed: () => _handleAllDone(stateProvider),
        child: Text(
          'All Done',
          style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
        ),
      );
    }
    return const SizedBox();
  }

  void _handleReadyToPickup(OrderItemStateProvider stateProvider) {
    stateProvider.handleUpdateItemsInfo(
      itemId: '',
      storeId: KdsConst.storeId,
      orderId: items.orderId,
      isDone: false,
      isInProgress: false,
      isCompleted: false,
      isReadyToPickup: true,
      isDelivered: false,
    );
  }

  void _handleAllDeliver(OrderItemStateProvider stateProvider) {
    stateProvider.handleUpdateItemsInfo(
      itemId: '',
      storeId: KdsConst.storeId,
      orderId: items.orderId,
      isDone: false,
      isInProgress: false,
      isCompleted: false,
      isReadyToPickup: false,
      isDelivered: true,
    );
  }

  void _handleAllDone(OrderItemStateProvider stateProvider) {
    stateProvider.handleUpdateItemsInfo(
      itemId: '',
      storeId: KdsConst.storeId,
      orderId: items.orderId,
      isDone: true,
      isInProgress: false,
      isCompleted: false,
      isReadyToPickup: false,
      isDelivered: false,
    );
  }

  Color _getOrderTypeColor(String orderType) {
    switch (orderType) {
      case KdsConst.pickup:
        return KdsConst.pickUpColor;
      case KdsConst.delivery:
        return KdsConst.mainColor;
      case KdsConst.dineIn:
        return KdsConst.dineInColor;
      default:
        return KdsConst.mainColor;
    }
  }
}

class OrderItem extends StatelessWidget {
  final OrderItemV2 item;
  final String orderId;
  final int selectedKdsId;
  final double fontSize;
  final bool isExpoScreen;
  final bool isDineIn;
  final double padding;

  const OrderItem({
    Key? key,
    required this.item,
    required this.orderId,
    required this.selectedKdsId,
    required this.fontSize,
    required this.isExpoScreen,
    required this.padding,
    required this.isDineIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderItemStateProvider>(
      builder: (context, stateProvider, _) {
        final itemState = stateProvider.getState('${item.itemId}-$orderId');
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.qty} ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize * 0.8),
                        ),
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize * 0.8,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (item.modifiers.isNotEmpty)
                      Text(
                        item.modifiers,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: fontSize * 0.8,
                        ),
                      ),
                  ],
                ),
              ),
              _buildActionButton(context, itemState, stateProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, dynamic itemState,
      OrderItemStateProvider stateProvider) {
    if (item.isDone) {
      return _buildUndoButton(context, itemState, stateProvider);
    } else if (isExpoScreen) {
      return _buildExpoScreenButton(itemState);
    } else {
      return _buildKitchenScreenButton(context, itemState, stateProvider);
    }
  }

  Widget _buildExpoScreenButton(dynamic itemState) {
    final isCompleteState = isDineIn ? item.isDelivered : item.isReadyToPickup;
    if (isCompleteState) {
      return Text('Completed',
          style: TextStyle(
              color: KdsConst.completedTextGreen,
              fontSize: fontSize * .8,
              fontWeight: FontWeight.bold));
    } else if (item.isInprogress) {
      return Text(
        'In Progress',
        style: TextStyle(
            color: KdsConst.orange,
            fontSize: fontSize * .8,
            fontWeight: FontWeight.bold),
      );
    } else {
      return Text(
        itemState.completeButtonText,
        style: TextStyle(
            color: itemState.completeButtonColor, fontSize: fontSize * .8),
      );
    }
  }

  Widget _buildKitchenScreenButton(BuildContext context, dynamic itemState,
      OrderItemStateProvider stateProvider) {
    final isCompleteState = isDineIn ? item.isDelivered : item.isReadyToPickup;
    if (isCompleteState) {
      return Text('Completed',
          style: TextStyle(
              color: KdsConst.completedTextGreen,
              fontSize: fontSize * .8,
              fontWeight: FontWeight.bold));
    } else if (item.isInprogress) {
      return ElevatedButton(
        style: _smallButtonStyle(KdsConst.green),
        onPressed: () => _handleInProcess(itemState, stateProvider),
        child: Text(
          itemState.countdown > 0 ? 'Done (${itemState.countdown})' : 'Done',
          style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
        ),
      );
    } else {
      return _buildStartProcessButton(context, itemState, stateProvider);
    }
  }

  Widget _buildUndoButton(BuildContext context, dynamic itemState,
      OrderItemStateProvider stateProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          style: _smallButtonStyle(KdsConst.red),
          onPressed: () => _handleUndoProcess(itemState, stateProvider),
          child: Text(
            "Undo",
            style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
          ),
        ),
        SizedBox(width: isExpoScreen && isDineIn ? 4.0 : 0),
        if (isExpoScreen && isDineIn)
          ElevatedButton(
            style: _smallButtonStyle(KdsConst.green),
            onPressed: () =>
                _handleDineInDeliverProcess(itemState, stateProvider),
            child: Text(
              "Serve",
              style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
            ),
          ),
        const SizedBox(width: 4.0),
      ],
    );
  }

  Widget _buildStartProcessButton(BuildContext context, dynamic itemState,
      OrderItemStateProvider stateProvider) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ElevatedButton(
        style: _smallButtonStyle(itemState.buttonColor),
        onPressed: () => _handleStartProcess(itemState, stateProvider),
        child: Text(
          itemState.countdown > 0
              ? 'Done (${itemState.countdown})'
              : itemState.buttonText,
          style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
        ),
      ),
    );
  }

  void _handleInProcess(
      dynamic itemState, OrderItemStateProvider stateProvider) {
    itemState.handleInProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: KdsConst.storeId,
      orderId: orderId,
    );
    // Add this line to update the state
    stateProvider.updateState('${item.itemId}-$orderId', itemState);
  }

  void _handleUndoProcess(
      dynamic itemState, OrderItemStateProvider stateProvider) {
    itemState.handleUndoProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: KdsConst.storeId,
      orderId: orderId,
    );
    stateProvider.updateState('${item.itemId}-$orderId', itemState);
  }

  void _handleDineInDeliverProcess(
      dynamic itemState, OrderItemStateProvider stateProvider) {
    itemState.handleDineInDeliverProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: KdsConst.storeId,
      orderId: orderId,
    );
    stateProvider.updateState('${item.itemId}-$orderId', itemState);
  }

  void _handleStartProcess(
      dynamic itemState, OrderItemStateProvider stateProvider) {
    itemState.handleStartProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: KdsConst.storeId,
      orderId: orderId,
    );
    stateProvider.updateState('${item.itemId}-$orderId', itemState);
  }
}

ButtonStyle _smallButtonStyle(Color buttonColor) {
  return ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(),
    backgroundColor: buttonColor,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    minimumSize: const Size(50, 30),
  );
}
