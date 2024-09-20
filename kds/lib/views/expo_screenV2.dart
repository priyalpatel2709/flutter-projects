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
import 'widgets/itemcartV2.dart';

class ExpoScreenV2 extends StatelessWidget {
  const ExpoScreenV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<KDSItemsProvider, AppSettingStateProvider>(
      builder: (BuildContext context, KDSItemsProvider kdsProvider,
              AppSettingStateProvider appSettingStateProvider, _) =>
          _ExpoScreenContent(
        kdsProvider: kdsProvider,
        appSettingStateProvider: appSettingStateProvider,
      ),
    );
  }
}

class _ExpoScreenContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;
  final AppSettingStateProvider appSettingStateProvider;

  const _ExpoScreenContent(
      {Key? key,
      required this.kdsProvider,
      required this.appSettingStateProvider})
      : super(key: key);

  @override
  _ExpoScreenContentState createState() => _ExpoScreenContentState();
}

class _ExpoScreenContentState extends State<_ExpoScreenContent> {
  String _activeFilter = KdsConst.defaultFilter;
  bool isHorizontal = false;
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
        title: 'All Orders: $_activeFilter (${_getFilteredOrders().length})',
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
        appSettingStateProvider: widget.appSettingStateProvider,
      ),
      body: Padding(
          padding: EdgeInsets.all(widget.appSettingStateProvider.padding),
          child: FilteredOrdersList(
            filteredOrders: _getFilteredOrders(),
            selectedKdsId: 0,
            isHorizontal: isHorizontal,
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
          isNewOrder: order.isNewOrder);
    }).where((order) {
      // print(
      //     'order--->${order.orderTitle} ${order.isAllDone} ${order.isAnyComplete}');
      return switch (_activeFilter) {
        KdsConst.defaultFilter => (order.isAnyInProgress ||
                order.isNewOrder ||
                order.isAnyDone ||
                order.isAllInProgress) ||
            (order.isAllDone && order.isAllComplete),
        KdsConst.doneFilter => order.isAllDone || order.isAnyComplete,
        _ => true
      };
    }).toList();
  }
}
