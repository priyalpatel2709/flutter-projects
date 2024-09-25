import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../constant/constants.dart';
import '../models/groupedorder_model.dart';
import '../providers/appsettings_provider.dart';
import '../providers/items_details_provider.dart';
import '../utils/utils.dart';
import 'widgets/appBar_widget.dart';
import 'widgets/filteredlist_widget.dart';
import 'widgets/itemcart.dart';

class MultiStationView extends StatelessWidget {
  const MultiStationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<KDSItemsProvider, AppSettingStateProvider>(
      builder: (BuildContext context, KDSItemsProvider kdsProvider,
              AppSettingStateProvider appSettingStateProvider, _) =>
          _MultiStationViewContent(
        kdsProvider: kdsProvider,
        appSettingStateProvider: appSettingStateProvider,
      ),
    );
  }
}

class _MultiStationViewContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;
  final AppSettingStateProvider appSettingStateProvider;

  const _MultiStationViewContent(
      {Key? key,
      required this.kdsProvider,
      required this.appSettingStateProvider})
      : super(key: key);

  @override
  _MultiStationViewContentState createState() =>
      _MultiStationViewContentState();
}

class _MultiStationViewContentState extends State<_MultiStationViewContent> {
  String _activeFilter = KdsConst.defaultFilter;

  @override
  void initState() {
    widget.kdsProvider.startFetching(
        timerInterval: KdsConst.timerInterval, storeId: KdsConst.storeId);
    super.initState();
    _activeFilter = widget.kdsProvider.expoFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Multi Station: $_activeFilter (${_getFilteredOrders().length})',
        onFilterSelected: (String value) {
          _setFilter(value);
          widget.kdsProvider.changeExpoFilter(value);
        },
        buildFilterMenu: _buildFilterMenu(context),
        appSettingStateProvider: widget.appSettingStateProvider,
      ),
      body: Padding(
          padding: EdgeInsets.all(widget.appSettingStateProvider.padding),
          child: FilteredOrdersList(
            filteredOrders: _getFilteredOrders(),
            selectedKdsId: 0,
            appSettingStateProvider: widget.appSettingStateProvider,
          )),
    );
  }

  void _setFilter(String filter) {
    setState(() => _activeFilter = filter);
  }

  List<PopupMenuItem<String>> _buildFilterMenu(BuildContext context) {
    final filterOptions = [
      (KdsConst.defaultFilter, KdsConst.defaultFilter),
      (KdsConst.doneFilter, KdsConst.doneFilter),
      (KdsConst.allFilter, KdsConst.allFilter),
    ];

    return filterOptions
        .map((option) => PopupMenuItem<String>(
              value: option.$1,
              child: Text(option.$2),
            ))
        .toList();
  }

  // Expo Screen
  List<GroupedOrder> _getFilteredOrders() {
    return widget.kdsProvider.groupedItems.map((order) {
      final uniqueItems = <String, OrderItemV2>{};

      for (var item in order.items) {
        uniqueItems.putIfAbsent('${item.itemId}_${item.itemName}', () => item);
      }

      // log('message--->${widget.appSettingStateProvider.selectedOrderType}');

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
        isAnyComplete: order.isAnyComplete,
        isAllComplete: order.isAllComplete,
        isNewOrder: order.isNewOrder,
      );
    }).where((order) {
      // Step 1: Apply filter based on the selectedOrderType
      if (widget.appSettingStateProvider.selectedOrderType != order.orderType) {
        return false;
      }

      // Step 2: Apply filter based on _activeFilter switch
      return switch (_activeFilter) {
        KdsConst.defaultFilter => !(order.isAnyDone == true ||
                order.isAnyComplete == true ||
                order.isAllInProgress == false ||
                order.isAllComplete == false) ||
            order.isNewOrder ||
            order.isAnyInProgress,
        KdsConst.doneFilter => order.isAllDone || order.isAllComplete,
        KdsConst.allFilter => true,
        _ => true
      };
    }).toList();
  }
}
