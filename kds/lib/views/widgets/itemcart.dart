import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/order_item_state_provider.dart';

class ItemCart extends StatelessWidget {
  final GroupedOrder items;
  final int? selectedKdsId;
  final double fontSize;
  final double padding;
  final bool isExpoScreen;
  final bool isFrontDesk;
  final bool isScheduleScreen;
  final String selectedView;
  final int storeId;

  const ItemCart({
    Key? key,
    required this.items,
    this.selectedKdsId,
    required this.fontSize,
    required this.padding,
    this.isExpoScreen = false,
    required this.selectedView,
    required this.storeId,
    required this.isFrontDesk,
    required this.isScheduleScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(padding + 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderHeader(
                      items: items,
                      fontSize: fontSize,
                      padding: padding,
                      isExpoScreen: isExpoScreen,
                      isFrontDesk: isFrontDesk,
                      selectedView: selectedView,
                      storeId: storeId,
                      isScheduleScreen: isScheduleScreen,
                    ),
                    const SizedBox(height: 4),
                    if (items.orderNote.isNotEmpty)
                      Text(
                        items.orderNote,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                    const Divider(),
                    _OrderItemList(
                        items: items,
                        fontSize: fontSize,
                        padding: padding,
                        selectedKdsId: selectedKdsId,
                        isExpoScreen: isExpoScreen,
                        storeId: storeId,
                        isScheduleScreen: isScheduleScreen),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final GroupedOrder items;
  final double fontSize;
  final double padding;
  final bool isExpoScreen;
  final bool isFrontDesk;
  final String selectedView;
  final bool isScheduleScreen;
  final int storeId;

  const _OrderHeader({
    Key? key,
    required this.items,
    required this.fontSize,
    required this.padding,
    required this.isExpoScreen,
    required this.isFrontDesk,
    required this.selectedView,
    required this.storeId,
    required this.isScheduleScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = _convertISOtoLocal('${items.createdOn}Z');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.0),
        gradient: LinearGradient(colors: [
          _getOrderTypeColor(items.orderType),
          Colors.white,
        ]),
        border: Border.all(color: KdsConst.black, width: .5),
      ),
      padding: EdgeInsets.all(padding + 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${items.orderTitle}',
                style: TextStyle(
                  color: KdsConst.black,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
              Text(
                items.orderType,
                style: TextStyle(
                  color: KdsConst.black,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
              Text(
                formattedTime,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize * 0.8,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          isScheduleScreen
              ? const SizedBox.shrink()
              : _ActionButton(
                  items: items,
                  isExpoScreen: isExpoScreen,
                  fontSize: fontSize,
                  storeId: storeId,
                  isFrontDesk: isFrontDesk),
        ],
      ),
    );
  }

  String _convertISOtoLocal(String isoTime) {
    DateTime dateTime = DateTime.parse(isoTime);
    DateTime pstDateTime = dateTime.toUtc().toLocal();
    return intl.DateFormat('hh:mm a').format(pstDateTime);
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

class _OrderItemList extends StatelessWidget {
  final GroupedOrder items;
  final double fontSize;
  final double padding;
  final int? selectedKdsId;
  final bool isExpoScreen;
  final bool isScheduleScreen;
  final int storeId;

  const _OrderItemList({
    Key? key,
    required this.items,
    required this.fontSize,
    required this.padding,
    this.selectedKdsId,
    required this.isExpoScreen,
    required this.storeId,
    required this.isScheduleScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
            storeId: storeId,
            isScheduleScreen: isScheduleScreen);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final GroupedOrder items;
  final bool isExpoScreen;
  final bool isFrontDesk;
  final double fontSize;
  final int storeId;

  const _ActionButton({
    Key? key,
    required this.items,
    required this.isExpoScreen,
    required this.fontSize,
    required this.storeId,
    required this.isFrontDesk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OrderItemStateProvider stateProvider =
        Provider.of<OrderItemStateProvider>(context, listen: false);

    if (isExpoScreen && !isFrontDesk) {
      if (items.orderType != KdsConst.dineIn && !items.isReadyToPickup) {
        return _buildButton(
          context,
          'Ready',
          KdsConst.green,
          () => _handleReadyToPickup(stateProvider),
        );
      } else {
        return _buildConditionalButton(
          context,
          'All Deliver',
          items.isAllDelivered || !items.isAllDone,
          KdsConst.green,
          () => _handleAllDeliver(stateProvider),
        );
      }
    } else if (isExpoScreen && isFrontDesk) {
      if (items.orderType != KdsConst.dineIn && !items.isReadyToPickup) {
        return Row(
          children: [
            _buildButton(
              context,
              'Inquire',
              KdsConst.green,
              () => _sandInjury(stateProvider),
            ),
            _buildButton(
              context,
              'Ready',
              KdsConst.green,
              () => _handleReadyToPickup(stateProvider),
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildButton(
              context,
              'Inquire',
              KdsConst.green,
              () => _sandInjury(stateProvider),
            ),
            _buildConditionalButton(
              context,
              'All Deliver',
              items.isAllDelivered || !items.isAllDone,
              KdsConst.green,
              () => _handleAllDeliver(stateProvider),
            ),
          ],
        );
      }
    } else if (_shouldShowAllDoneButton()) {
      return _buildButton(
        context,
        'All Done',
        KdsConst.darkGreen,
        () => _handleAllDone(stateProvider),
      );
    }
    return const SizedBox();
  }

  bool _shouldShowAllDoneButton() {
    return (!items.isAllDone && items.isDineIn)
        ? !items.isAllDelivered
        : !items.isReadyToPickup;
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        style: _smallButtonStyle(color),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
        ),
      ),
    );
  }

  Widget _buildConditionalButton(BuildContext context, String text,
      bool condition, Color color, VoidCallback onPressed) {
    if (condition) return const SizedBox.shrink();
    return _buildButton(context, text, color, onPressed);
  }

  void _handleReadyToPickup(OrderItemStateProvider stateProvider) {
    stateProvider.handleUpdateItemsInfo(
      itemId: '',
      storeId: storeId,
      orderId: items.orderId,
      isReadyToPickup: true,
      isDone: false,
      isInProgress: false,
      isCompleted: false,
      isDelivered: false,
    );
  }

  void _sandInjury(OrderItemStateProvider stateProvider) {
    stateProvider.sandInjury(
        orderId: items.orderId, orderTitle: items.orderTitle);
  }

  void _handleAllDeliver(OrderItemStateProvider stateProvider) {
    stateProvider.handleUpdateItemsInfo(
      itemId: '',
      storeId: storeId,
      orderId: items.orderId,
      isDelivered: true,
      isDone: false,
      isInProgress: false,
      isCompleted: false,
      isReadyToPickup: false,
    );
  }

  void _handleAllDone(OrderItemStateProvider stateProvider) {
    stateProvider.handleUpdateItemsInfo(
      itemId: '',
      storeId: storeId,
      orderId: items.orderId,
      isDone: true,
      isInProgress: false,
      isCompleted: false,
      isDelivered: false,
      isReadyToPickup: false,
    );
  }
}

class OrderItem extends StatelessWidget {
  final OrderItemModel item;
  final String orderId;
  final int selectedKdsId;
  final double fontSize;
  final bool isExpoScreen;
  final bool isDineIn;
  final bool isScheduleScreen;
  final double padding;
  final int storeId;

  const OrderItem({
    Key? key,
    required this.item,
    required this.orderId,
    required this.selectedKdsId,
    required this.fontSize,
    required this.isExpoScreen,
    required this.padding,
    required this.isDineIn,
    required this.storeId,
    required this.isScheduleScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderItemStateProvider>(
      builder: (context, stateProvider, _) {
        final itemState = stateProvider.getState(
          itemId: '${item.itemId}-$orderId',
          isInProgress: item.isInProgress,
          isReadyToPickup: item.isReadyToPickup,
          isDelivered: item.isDelivered, isDone: item.isDone,
          // isCompleted: item.isc
        );
        final bool isDisabled =
            stateProvider.isButtonDisabled('${item.itemId}-$orderId');
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
                      children: [
                        Text(
                          '${item.qty} ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize * 0.8),
                        ),
                        Expanded(
                          child: Text(
                            '  ${item.itemName}',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
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
              isScheduleScreen
                  ? const SizedBox.shrink()
                  : _buildActionButton(
                      context, itemState, stateProvider, isDisabled, storeId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, dynamic itemState,
      OrderItemStateProvider stateProvider, bool isDisabled, int storeId) {
    if (itemState.isDone) {
      return _buildUndoButton(
          context, itemState, stateProvider, isDisabled, storeId);
    } else if (isExpoScreen) {
      return _buildExpoScreenButton(itemState);
    } else {
      return _buildKitchenScreenButton(
          context, itemState, stateProvider, isDisabled, storeId);
    }
  }

  Widget _buildExpoScreenButton(dynamic itemState) {
    final isCompleteState =
        isDineIn ? itemState.isDelivered : itemState.isReadyToPickup;
    if (isCompleteState) {
      return const Text('Completed',
          style: TextStyle(fontWeight: FontWeight.bold));
    } else if (itemState.isInProgress) {
      return const Text('In Progress',
          style: TextStyle(fontWeight: FontWeight.bold));
    } else {
      return const Text('Start', style: TextStyle(fontWeight: FontWeight.bold));
    }
  }

  Widget _buildKitchenScreenButton(BuildContext context, dynamic itemState,
      OrderItemStateProvider stateProvider, bool isDisabled, int storeId) {
    final isCompleteState = isDineIn ? item.isDelivered : item.isReadyToPickup;
    if (isCompleteState) {
      return const Text('Completed',
          style: TextStyle(fontWeight: FontWeight.bold));
    } else if (itemState.isInProgress) {
      return _buildButton(
          context,
          itemState.countdown <= 0 ? 'Done' : 'Done (${itemState.countdown})',
          KdsConst.green,
          () => itemState.countdown != 0
              ? null
              : _handleInProcess(itemState, stateProvider, storeId),
          isDisabled);
    } else {
      return _buildButton(
          context,
          itemState.buttonText,
          itemState.buttonColor,
          () => _handleStartProcess(itemState, stateProvider, storeId),
          isDisabled);
    }
  }

  Widget _buildUndoButton(BuildContext context, dynamic itemState,
      OrderItemStateProvider stateProvider, bool isDisabled, int storeId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildButton(
            context,
            'Undo',
            KdsConst.red,
            () => _handleUndoProcess(itemState, stateProvider, storeId),
            isDisabled),
        if (isExpoScreen && isDineIn)
          _buildButton(
              context,
              'Serve',
              KdsConst.green,
              () => _handleDineInDeliverProcess(
                  itemState, stateProvider, storeId),
              isDisabled),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color,
      VoidCallback onPressed, bool isDisabled) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ElevatedButton(
        style: _smallButtonStyle(color),
        onPressed: isDisabled ? null : onPressed,
        child: isDisabled
            ? const CircularProgressIndicator(
                strokeCap: StrokeCap.square,
                color: KdsConst.black,
                strokeWidth: .5,
                backgroundColor: KdsConst.white,
              )
            : Text(
                text,
                style:
                    TextStyle(color: KdsConst.black, fontSize: fontSize * .8),
              ),
      ),
    );
  }

  void _handleInProcess(
    dynamic itemState,
    OrderItemStateProvider stateProvider,
    int storeId,
  ) {
    itemState.handleInProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: storeId,
      orderId: orderId,
    );
    stateProvider.updateState('${item.itemId}-$orderId', itemState);
  }

  void _handleUndoProcess(
      dynamic itemState, OrderItemStateProvider stateProvider, int storeId) {
    itemState.handleUndoProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: storeId,
      orderId: orderId,
    );
    stateProvider.updateState('${item.itemId}-$orderId', itemState);
  }

  void _handleDineInDeliverProcess(
      dynamic itemState, OrderItemStateProvider stateProvider, int storeId) {
    itemState.handleDineInDeliverProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: storeId,
      orderId: orderId,
    );
    stateProvider.updateState('${item.itemId}-$orderId', itemState);
  }

  void _handleStartProcess(
      dynamic itemState, OrderItemStateProvider stateProvider, int storeId) {
    itemState.handleStartProcess(
      provider: stateProvider,
      itemId: item.itemId,
      storeId: storeId,
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
