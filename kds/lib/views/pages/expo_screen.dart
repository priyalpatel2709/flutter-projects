// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/appsettings_provider.dart';
import '../../providers/items_details_provider.dart';
import '../widgets/appBar_widget.dart';
import '../widgets/filteredlist_widget.dart';

class ExpoView extends StatelessWidget {
  const ExpoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<KDSItemsProvider, AppSettingStateProvider>(
      builder: (BuildContext context, KDSItemsProvider kdsProvider,
              AppSettingStateProvider appSettingStateProvider, _) =>
          _ExpoViewContent(
        kdsProvider: kdsProvider,
        appSettingStateProvider: appSettingStateProvider,
      ),
    );
  }
}

class _ExpoViewContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;
  final AppSettingStateProvider appSettingStateProvider;

  const _ExpoViewContent({
    super.key,
    required this.kdsProvider,
    required this.appSettingStateProvider,
  });

  @override
  _ExpoViewState createState() => _ExpoViewState();
}

class _ExpoViewState extends State<_ExpoViewContent> {
  String _activeFilter = KdsConst.defaultFilter;

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.kdsProvider.expoFilter;
  }

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  List<PopupMenuItem<String>> _buildFilterMenu() {
    return [KdsConst.defaultFilter, KdsConst.doneFilter, KdsConst.allFilter]
        .map(
          (filter) => PopupMenuItem<String>(
            value: filter,
            child: Text(filter),
          ),
        )
        .toList();
  }

  List<GroupedOrder> _getFilteredOrders() {
    return widget.kdsProvider.groupedItems.map((order) {
      // Map items by unique id and name combination
      final uniqueItems = <String, OrderItemV2>{};
      for (var item in order.items) {
        uniqueItems['${item.itemId}_${item.itemName}'] = item;
      }

      return GroupedOrder(
        id: order.id,
        items: uniqueItems.values.toList(),
        kdsId: order.kdsId,
        orderId: order.orderId,
        orderTitle: order.orderTitle,
        orderType: order.orderType,
        orderNote: order.orderNote,
        createdOn: order.createdOn,
        storeId: order.storeId,
        tableName: order.tableName,
        displayOrderType: order.displayOrderType,
        isAllInProgress: order.isAllInProgress,
        isAllDone: order.isAllDone,
        isAllCancel: order.isAllCancel,
        isAnyInProgress: order.isAnyInProgress,
        isAnyDone: order.isAnyDone,
        isNewOrder: order.isNewOrder,
        isDineIn: order.isDineIn,
        deliveredOn: order.deliveredOn,
        isAllDelivered: order.isAllDelivered,
        isAnyDelivered: order.isAnyDelivered,
        isDelivered: order.isDelivered,
        isReadyToPickup: order.isReadyToPickup,
        readyToPickupOn: order.readyToPickupOn,
      );
    }).where((order) {
      // Filter based on selected order type
      if (widget.appSettingStateProvider.selectedOrderType == KdsConst.dineIn) {
        return order.orderType == KdsConst.dineIn && _applyActiveFilter(order);
      } else if (widget.appSettingStateProvider.selectedOrderType ==
          KdsConst.pickup) {
        return order.orderType != KdsConst.dineIn && _applyActiveFilter(order);
      }

      // If no specific order type is selected, just apply the active filter
      return _applyActiveFilter(order);
    }).toList();
  }

  bool _applyActiveFilter(GroupedOrder order) {
    return switch (_activeFilter) {
      KdsConst.defaultFilter =>
        order.isDineIn ? !order.isAllDelivered : !order.isReadyToPickup,
      KdsConst.doneFilter =>
        order.isDineIn ? order.isAllDelivered : order.isReadyToPickup,
      KdsConst.allFilter => true,
      _ => true
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        filterName: _activeFilter,
        screenName: 'Expo View',
        orderLength: _getFilteredOrders().length,
        onFilterSelected: (String value) {
          _setFilter(value);
          widget.kdsProvider.changeExpoFilter(value);
        },
        buildFilterMenu: _buildFilterMenu(),
        appSettingStateProvider: widget.appSettingStateProvider,
      ),
      body: Padding(
        padding: EdgeInsets.all(widget.appSettingStateProvider.padding),
        child: FilteredOrdersList(
          filteredOrders: _getFilteredOrders(),
          selectedKdsId: 0,
          isExpoScree: true,
          appSettingStateProvider: widget.appSettingStateProvider,
          error: widget.kdsProvider.itemsError,
        ),
      ),
    );
  }
}
