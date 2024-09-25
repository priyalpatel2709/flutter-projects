import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

class StationScreenV2 extends StatelessWidget {
  const StationScreenV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<KDSItemsProvider, AppSettingStateProvider>(
      builder: (BuildContext context, KDSItemsProvider kdsProvider,
              AppSettingStateProvider appSettingStateProvider, _) =>
          _StationScreenContent(
        kdsProvider: kdsProvider,
        appSettingStateProvider: appSettingStateProvider,
      ),
    );
  }
}

class _StationScreenContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;
  final AppSettingStateProvider appSettingStateProvider;
  const _StationScreenContent(
      {Key? key,
      required this.kdsProvider,
      required this.appSettingStateProvider})
      : super(key: key);

  @override
  _StationScreenContentState createState() => _StationScreenContentState();
}

class _StationScreenContentState extends State<_StationScreenContent> {
  int? selectedKdsId;
  String _activeFilter = KdsConst.defaultFilter;

  @override
  void initState() {
    super.initState();

    // widget.kdsProvider.startFetching(
    //     timerInterval: KdsConst.timerInterval, storeId: KdsConst.storeId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.kdsProvider.stations.isNotEmpty) {
        setState(() {
          selectedKdsId = widget.kdsProvider.stations.first.kdsId;
          widget.kdsProvider.updateFilters(kdsId: selectedKdsId);
          _activeFilter = widget.kdsProvider.stationFilter;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title:
            'Station ($selectedKdsId) : $_activeFilter (${_getFilteredOrders().length})',
        onFilterSelected: (String value) {
          _setFilter(value);
          widget.kdsProvider.changeExpoFilter(value);
        },
        buildFilterMenu: _buildFilterMenu(context),
        appSettingStateProvider: widget.appSettingStateProvider,
      ),
      body: Padding(
        padding: EdgeInsets.all(widget.appSettingStateProvider.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStationSelector(),
            const SizedBox(height: 5),
            Expanded(
              child: FilteredOrdersList(
                filteredOrders: _getFilteredOrders(),
                selectedKdsId: selectedKdsId ?? 0,
                appSettingStateProvider: widget.appSettingStateProvider,
              ),
            )
          ],
        ),
      ),
    );
  }

  List<GroupedOrder> _filterByKdsId() {
    if (selectedKdsId == null) {
      return [];
    }

    return widget.kdsProvider.groupedItems
        .map((order) {
          final filteredItems =
              order.items.where((item) => item.kdsId == selectedKdsId).toList();

          if (filteredItems.isNotEmpty) {
            return GroupedOrder(
                orderId: order.orderId,
                items: filteredItems,
                kdsId: order.kdsId,
                id: order.id,
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
          }
          return null;
        })
        .where((order) => order != null)
        .cast<GroupedOrder>()
        .toList();
  }

  List<GroupedOrder> _getFilteredOrders() {
    List<GroupedOrder> filteredByKdsId = _filterByKdsId();

    return filteredByKdsId.where((order) {
      switch (_activeFilter) {
        case KdsConst.defaultFilter:
          return order.isAnyInProgress || order.isNewOrder;
        case KdsConst.doneFilter:
          return order.isAllDone || order.isAnyComplete;
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildStationSelector() {
    if (widget.kdsProvider.stationsError.isNotEmpty) {
      return Center(child: Text(widget.kdsProvider.stationsError));
    }

    if (widget.kdsProvider.stations.isEmpty) {
      return const Center(child: Text('No stations available'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButton<int>(
        isExpanded: true,
        hint: const Text('Select Station'),
        value: selectedKdsId,
        onChanged: _updateSelectedStation,
        items: widget.kdsProvider.stations
            .map((station) => DropdownMenuItem<int>(
                  value: station.kdsId,
                  child: Text(station.name ?? 'Unnamed Station'),
                ))
            .toList(),
      ),
    );
  }

  void _updateSelectedStation(int? value) {
    setState(() {
      selectedKdsId = value;
      _updateFilters();
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _updateFilters();
    });
  }

  void _updateFilters() {
    widget.kdsProvider.updateFilters(
      isInProgress: _activeFilter == 'In Progress',
      isDone: _activeFilter == 'Done',
      kdsId: selectedKdsId,
    );
  }

  List<PopupMenuEntry<String>> _buildFilterMenu(BuildContext context) {
    return ['In Progress', 'Done']
        .map((filter) =>
            PopupMenuItem<String>(value: filter, child: Text(filter)))
        .toList();
  }
}
