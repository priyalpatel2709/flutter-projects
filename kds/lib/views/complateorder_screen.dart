import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../constant/constants.dart';
import '../models/groupedorder_model.dart';
import '../providers/items_details_provider.dart';
import '../utils/utils.dart';
import 'widgets/appBar_widget.dart';
import 'widgets/filteredlist_widget.dart';
import 'widgets/itemcartV2.dart';

class CompleteOrder extends StatelessWidget {
  const CompleteOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<KDSItemsProvider>(
      builder: (context, kdsProvider, child) => _CompleteOrderContent(
        kdsProvider: kdsProvider,
      ),
    );
  }
}

class _CompleteOrderContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;
  const _CompleteOrderContent({super.key, required this.kdsProvider});

  @override
  _CompleteOrderState createState() => _CompleteOrderState();
}

class _CompleteOrderState extends State<_CompleteOrderContent> {
  String _activeFilter = KdsConst.defaultFilter;
  bool isHorizontal = false;

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
      );
    }).where((order) {
      return switch (_activeFilter) {
        KdsConst.defaultFilter => order.items.any((item) => !item.isComplete),
        KdsConst.doneFilter => order.items.every((item) => item.isComplete),
        _ => true
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title:
            'Complete Order: $_activeFilter (${_getFilteredOrders().length})',
        isHorizontal: isHorizontal,
        iconOnPress: () {
          setState(() {
            isHorizontal = !isHorizontal;
          });
        },
        onFilterSelected: (String value) {
          _setFilter(value);
          widget.kdsProvider.changeExpoFilter(value);
        },
        buildFilterMenu: _buildFilterMenu(context),
      ),
      body: Padding(
          padding: EdgeInsets.all(Utils.getPadding(context)),
          child: FilteredOrdersList(
            filteredOrders: _getFilteredOrders(),
            selectedKdsId: 0,
            isHorizontal: isHorizontal,
            isComplete: true,
          )),
    );
  }
}
