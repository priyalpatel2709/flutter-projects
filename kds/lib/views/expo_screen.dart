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
  const _ExpoViewContent(
      {super.key,
      required this.kdsProvider,
      required this.appSettingStateProvider});

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
      if (widget.appSettingStateProvider.selectedOrderType != order.orderType) {
        return false;
      }
      return switch (_activeFilter) {
        KdsConst.defaultFilter => !order.isAllComplete,
        KdsConst.doneFilter => order.isAllComplete,
        KdsConst.allFilter => true,
        _ => true
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Expo View: $_activeFilter (${_getFilteredOrders().length})',
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
            isComplete: true,
            appSettingStateProvider: widget.appSettingStateProvider,
          )),
    );
  }
}
