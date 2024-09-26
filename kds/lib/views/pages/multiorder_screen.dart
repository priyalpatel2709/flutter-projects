import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/appsettings_provider.dart';
import '../../providers/items_details_provider.dart';
import '../widgets/appBar_widget.dart';
import '../widgets/filteredlist_widget.dart';

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

  const _MultiStationViewContent({
    Key? key,
    required this.kdsProvider,
    required this.appSettingStateProvider,
  }) : super(key: key);

  @override
  _MultiStationViewContentState createState() =>
      _MultiStationViewContentState();
}

class _MultiStationViewContentState extends State<_MultiStationViewContent> {
  String _activeFilter = KdsConst.defaultFilter;

  @override
  void initState() {
    super.initState();
    widget.kdsProvider.startFetching(
      timerInterval: KdsConst.timerInterval,
      storeId: KdsConst.storeId,
    );
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
        buildFilterMenu: _buildFilterMenu(),
        appSettingStateProvider: widget.appSettingStateProvider,
      ),
      body: Padding(
        padding: EdgeInsets.all(widget.appSettingStateProvider.padding),
        child: FilteredOrdersList(
          filteredOrders: _getFilteredOrders(),
          selectedKdsId: 0,
          appSettingStateProvider: widget.appSettingStateProvider,
        ),
      ),
    );
  }

  void _setFilter(String filter) {
    setState(() => _activeFilter = filter);
  }

  List<PopupMenuItem<String>> _buildFilterMenu() {
    return [KdsConst.defaultFilter, KdsConst.doneFilter, KdsConst.allFilter]
        .map((filter) => PopupMenuItem<String>(
              value: filter,
              child: Text(filter),
            ))
        .toList();
  }

  List<GroupedOrder> _getFilteredOrders() {
    return widget.kdsProvider.groupedItems.map((order) {
      final uniqueItems = <String, OrderItemV2>{};

      // Ensure uniqueness based on itemId and itemName
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
      // Filter by selected order type
      if (widget.appSettingStateProvider.selectedOrderType !=
              KdsConst.allFilter &&
          widget.appSettingStateProvider.selectedOrderType != order.orderType) {
        return false;
      }

      // Filter based on the active filter
      return switch (_activeFilter) {
        KdsConst.defaultFilter => (order.isNewOrder || order.isAnyInProgress) &&
            (order.isAnyDone == true ||
                order.isAnyComplete == true ||
                order.isAllInProgress == false ||
                order.isAllComplete == false),
        KdsConst.doneFilter => order.isAllDone || order.isAllComplete,
        KdsConst.allFilter => true,
        _ => true,
      };
    }).toList();
  }
}
