import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/appsettings_provider.dart';
import '../../providers/items_details_provider.dart';
import '../widgets/appBar_widget.dart';
import '../widgets/filteredlist_widget.dart';

class StationScreen extends StatelessWidget {
  const StationScreen({super.key});

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

  const _StationScreenContent({
    Key? key,
    required this.kdsProvider,
    required this.appSettingStateProvider,
  }) : super(key: key);

  @override
  _StationScreenContentState createState() => _StationScreenContentState();
}

class _StationScreenContentState extends State<_StationScreenContent> {
  int? selectedKdsId;
  String _activeFilter = KdsConst.defaultFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedKdsId = widget.appSettingStateProvider.selectedStation;
      if (widget.kdsProvider.stations.isNotEmpty) {
        // widget.kdsProvider.updateFilters(
        //     kdsId: widget.appSettingStateProvider.selectedStation);

        setState(() {
          _activeFilter = widget.kdsProvider.stationFilter;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        filterName: _activeFilter,
        screenName: KdsConst.singleStationScreen,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.kdsProvider.stationsError == ''
                ? _buildStationSelector()
                : Text(widget.kdsProvider.stationsError,
                    style: const TextStyle(color: KdsConst.red, fontSize: 16)),
            const SizedBox(height: 5),
            Expanded(
              child: FilteredOrdersList(
                filteredOrders: _getFilteredOrders(),
                selectedKdsId: selectedKdsId ?? 0,
                appSettingStateProvider: widget.appSettingStateProvider,
                error: widget.kdsProvider.itemsError,
              ),
            ),
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
              // isAnyComplete: order.isAnyComplete,
              // isAllComplete: order.isAllComplete,
              isNewOrder: order.isNewOrder,
              isDineIn: order.isDineIn,
              deliveredOn: order.deliveredOn,
              isAllDelivered: order.isAllDelivered,
              isAnyDelivered: order.isAnyDelivered,
              isDelivered: order.isDelivered,
              isReadyToPickup: order.isReadyToPickup,
              readyToPickupOn: order.readyToPickupOn,
            );
          }
          return null;
        })
        .whereType<GroupedOrder>() // This removes any null values
        .toList();
  }

  List<GroupedOrder> _getFilteredOrders() {
    List<GroupedOrder> filteredByKdsId = _filterByKdsId();

    return filteredByKdsId.where((order) {
      // Check order type filter
      bool passesOrderTypeFilter = true;
      if (widget.appSettingStateProvider.selectedOrderType == KdsConst.dineIn) {
        passesOrderTypeFilter = order.orderType == KdsConst.dineIn;
      } else if (widget.appSettingStateProvider.selectedOrderType ==
          KdsConst.pickup) {
        passesOrderTypeFilter = order.orderType != KdsConst.dineIn;
      }

      // Check active filter
      bool passesActiveFilter = switch (_activeFilter) {
        KdsConst.defaultFilter => (order.isNewOrder ||
                order.isAnyInProgress ||
                order.isAllInProgress) ||
            (order.isAllDone),
        KdsConst.doneFilter =>
          order.isAllDone || order.isAllDelivered || order.isReadyToPickup,
        KdsConst.allFilter => true,
        _ => true,
      };

      // Return true only if both filters pass
      return passesOrderTypeFilter && passesActiveFilter;
    }).toList();
  }

  Widget _buildStationSelector() {
    if (widget.kdsProvider.stationsError.isNotEmpty) {
      return Center(
        child: Text('Error: ${widget.kdsProvider.stationsError}'),
      );
    }

    if (widget.kdsProvider.stations.isEmpty) {
      return const Center(
        child: Text('No stations available. Please try again later.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButton<int>(
        isExpanded: true,
        hint: const Text('Select Station'),
        value: selectedKdsId,
        onChanged: _updateSelectedStation,
        items: widget.kdsProvider.stations
            .map(
              (station) => DropdownMenuItem<int>(
                value: station.kdsId,
                child: Text(station.name ?? 'Unnamed Station'),
              ),
            )
            .toList(),
      ),
    );
  }

  void _updateSelectedStation(int? value) {
    widget.appSettingStateProvider.changeSelectedStation(value ?? 1);
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
    // widget.kdsProvider.updateFilters(
    //   isInProgress: _activeFilter == KdsConst.defaultFilter,
    //   isDone: _activeFilter == KdsConst.doneFilter,
    //   kdsId: selectedKdsId,
    // );
  }

  List<PopupMenuEntry<String>> _buildFilterMenu() {
    return [
      KdsConst.defaultFilter,
      KdsConst.doneFilter,
      KdsConst.allFilter,
    ]
        .map(
          (filter) => PopupMenuItem<String>(
            value: filter,
            child: Text(filter),
          ),
        )
        .toList();
  }
}
