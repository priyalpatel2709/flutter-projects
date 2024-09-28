import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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
    final createdOnDate =
        DateTime.tryParse(items.createdOn)?.toLocal() ?? DateTime.now();
    final formattedCreatedOn = DateFormat('hh:mm a').format(createdOnDate);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(context, formattedCreatedOn),
            const SizedBox(height: 4),
            Text(
              items.orderNote,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.items.length,
              itemBuilder: (context, index) => OrderItem(
                  item: items.items[index],
                  orderId: items.orderId,
                  selectedKdsId: selectedKdsId ?? 0,
                  fontSize: fontSize,
                  isComplete: isComplete,
                  padding: padding,
                  isDineIn: items.isDineIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, String formattedCreatedOn) {
    return Consumer<OrderItemStateProvider>(
      builder: (context, stateProvider, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0.0),
          color: _getOrderTypeColor(items.orderType),
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
                      fontSize: fontSize),
                ),
                Text(
                  '#${items.orderTitle}',
                  style: TextStyle(
                      color: KdsConst.black,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedCreatedOn,
                  style: TextStyle(color: KdsConst.black, fontSize: fontSize),
                ),
                isComplete
                    ? items.orderType != KdsConst.dineIn
                        ? Padding(
                            padding: EdgeInsets.all(8 + padding),
                            child: ElevatedButton(
                              style: _smallButtonStyle(KdsConst.green),
                              onPressed: () {
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
                              },
                              child: Text('Ready To PickUp',
                                  style: TextStyle(
                                      color: KdsConst.black,
                                      fontSize: fontSize * .8)),
                            ),
                          )
                        : const SizedBox()
                    : Visibility(
                        visible: !items.isAllDone,
                        child: ElevatedButton(
                          style: _smallButtonStyle(KdsConst.green),
                          onPressed: () => stateProvider.handleUpdateItemsInfo(
                            itemId: '',
                            storeId: KdsConst.storeId,
                            orderId: items.orderId,
                            isDone: true,
                            isInProgress: false,
                            isCompleted: false,
                            isReadyToPickup: false,
                            isDelivered: false,
                          ),
                          child: Text(
                            'All  Done',
                            style: TextStyle(
                                color: KdsConst.black, fontSize: fontSize * .5),
                          ),
                        ),
                      )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getOrderTypeColor(String orderType) {
    switch (orderType) {
      case KdsConst.pickup:
        return KdsConst.yellow;
      case KdsConst.delivery:
        return KdsConst.red;
      default:
        return KdsConst.blue;
    }
  }
}

class OrderItem extends StatelessWidget {
  final OrderItemV2 item;
  final String orderId;
  final int selectedKdsId;
  final double fontSize;
  final bool isComplete;
  final bool isDineIn;
  final double padding;

  const OrderItem({
    Key? key,
    required this.item,
    required this.orderId,
    required this.selectedKdsId,
    required this.fontSize,
    required this.isComplete,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${item.qty} ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: fontSize),
                        ),
                        Expanded(
                          child: Text(
                            item.itemName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize * 0.8),
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
                            fontSize: fontSize * 0.8),
                      ),
                  ],
                ),
              ),
              _buildActionButton(
                context,
                itemState,
                stateProvider,
                isDineIn,
                isComplete,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, itemState,
      OrderItemStateProvider stateProvider, bool isDineIn, bool isComplete) {
    if (item.isDone) {
      return isComplete
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildUndoButton(
                    context, itemState, stateProvider, isComplete, isDineIn),
                // _buildCompleteButton(
                //     context, itemState, stateProvider, isDineIn),
              ],
            )
          : _buildUndoButton(
              context, itemState, stateProvider, isComplete, isDineIn);
    } else {
      return isComplete
          ? item.isComplete
              ? const Icon(Icons.check_circle, color: Colors.green)
              : Text(itemState.completeButtonText,
                  style: TextStyle(
                      color: itemState.completeButtonColor,
                      fontSize: fontSize * .8))
          : item.isComplete
              ? const Icon(Icons.check_circle, color: Colors.green)
              : _buildStartProcessButton(context, itemState, stateProvider);
    }
  }

  Widget _buildCompleteButton(BuildContext context, itemState,
      OrderItemStateProvider stateProvider, bool isDineIn) {
    return Padding(
      padding: EdgeInsets.all(8 + padding),
      child: ElevatedButton(
        style: _smallButtonStyle(KdsConst.green),
        onPressed: () => itemState.handleCompleteProcess(
            provider: stateProvider,
            itemId: item.itemId,
            storeId: KdsConst.storeId,
            orderId: orderId,
            isDineIn: isDineIn),
        child: Text(isDineIn ? 'Deliver' : 'Ready To PickUp',
            style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8)),
      ),
    );
  }

  Widget _buildUndoButton(BuildContext context, itemState,
      OrderItemStateProvider stateProvider, bool isComplete, bool isDineIn) {
    return Row(
      children: [
        ElevatedButton(
          style: _smallButtonStyle(KdsConst.red),
          onPressed: () {
            itemState.handleUndoProcess(
              provider: stateProvider,
              itemId: item.itemId,
              storeId: KdsConst.storeId,
              orderId: orderId,
            );
            stateProvider.updateState('${item.itemId}-$orderId', itemState);
          },
          child: Text("Undo",
              style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8)),
        ),
        const SizedBox(
          width: 8.0,
        ),
        Visibility(
          visible: isComplete && isDineIn,
          child: ElevatedButton(
            style: _smallButtonStyle(KdsConst.green),
            onPressed: () {
              itemState.handleDineInDeliverProcess(
                provider: stateProvider,
                itemId: item.itemId,
                storeId: KdsConst.storeId,
                orderId: orderId,
              );
              stateProvider.updateState('${item.itemId}-$orderId', itemState);
            },
            child: Text("Deliver",
                style:
                    TextStyle(color: KdsConst.black, fontSize: fontSize * .8)),
          ),
        ),
        const SizedBox(
          width: 8.0,
        ),
      ],
    );
  }

  Widget _buildStartProcessButton(
      BuildContext context, itemState, OrderItemStateProvider stateProvider) {
    return Padding(
      padding: EdgeInsets.all(8 + padding),
      child: ElevatedButton(
        style: _smallButtonStyle(itemState.buttonColor),
        onPressed: () {
          itemState.handleStartProcess(
            provider: stateProvider,
            itemId: item.itemId,
            storeId: KdsConst.storeId,
            orderId: orderId,
          );
          stateProvider.updateState('${item.itemId}-$orderId', itemState);
        },
        child: Text(
          itemState.countdown > 0
              ? 'Done (${itemState.countdown})'
              : itemState.buttonText,
          style:
              TextStyle(color: KdsConst.onMainColor, fontSize: fontSize * .8),
        ),
      ),
    );
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
