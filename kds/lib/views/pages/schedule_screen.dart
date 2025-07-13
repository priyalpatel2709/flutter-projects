// import 'dart:ffi';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/appsettings_provider.dart';
import '../../providers/items_details_provider.dart';
import '../../providers/order_item_state_provider.dart';
import '../widgets/appBar_widget.dart';
import '../widgets/filteredlist_widget.dart';

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<KDSItemsProvider, AppSettingStateProvider,
        OrderItemStateProvider>(
      builder: (BuildContext context,
              KDSItemsProvider kdsProvider,
              AppSettingStateProvider appSettingStateProvider,
              OrderItemStateProvider orderItemStateProvider,
              _) =>
          _ScheduleContent(
        kdsProvider: kdsProvider,
        appSettingStateProvider: appSettingStateProvider,
        orderItemStateProvider: orderItemStateProvider,
      ),
    );
  }
}

class _ScheduleContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;
  final AppSettingStateProvider appSettingStateProvider;
  final OrderItemStateProvider orderItemStateProvider;

  const _ScheduleContent({
    super.key,
    required this.kdsProvider,
    required this.appSettingStateProvider,
    required this.orderItemStateProvider,
  });

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<_ScheduleContent> {
  String _activeFilter = KdsConst.defaultFilter;
  Future<List<GroupedOrder>>? _scheduleOrdersFuture; // Store the future

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.kdsProvider.expoFilter;
    _scheduleOrdersFuture =
        _fetchScheduleOrders(); // Initialize the future here
  }

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
    });
  }

  // List<PopupMenuItem<String>> _buildFilterMenu() {
  //   return [KdsConst.defaultFilter, KdsConst.doneFilter, KdsConst.allFilter]
  //       .map(
  //         (filter) => PopupMenuItem<String>(
  //           value: filter,
  //           child: Text(filter),
  //         ),
  //       )
  //       .toList();
  // }

  // bool _applyActiveFilter(GroupedOrder order) {
  //   return switch (_activeFilter) {
  //     KdsConst.defaultFilter =>
  //       order.isDineIn ? !order.isAllDelivered : !order.isReadyToPickup,
  //     KdsConst.doneFilter =>
  //       order.isDineIn ? order.isAllDelivered : order.isReadyToPickup,
  //     KdsConst.allFilter => true,
  //     _ => true
  //   };
  // }

  Future<List<GroupedOrder>> _fetchScheduleOrders() async {
    log('does method work?');
    await widget.kdsProvider.getScheduleOrder(storeId: '1');
    return widget.kdsProvider.scheduleGroupedItems; // Return the fetched items
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        filterName: _activeFilter,
        screenName: KdsConst.expoScreen,
        orderLength: 0, // Update as needed
        onFilterSelected: (String value) {
          _setFilter(value);
          widget.kdsProvider.changeExpoFilter(value);
        },
        buildFilterMenu: [],
        appSettingStateProvider: widget.appSettingStateProvider,
        showFilterButton: false,
        hubConnectionState: widget.orderItemStateProvider.hubState,
      ),
      body: FutureBuilder<List<GroupedOrder>>(
        future: _scheduleOrdersFuture, // Use the stored future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No scheduled orders found.'));
          }

          final scheduleGroupedItems = snapshot.data!;

          return FilteredOrdersList(
            filteredOrders: scheduleGroupedItems,
            selectedKdsId: 0,
            isScheduleScreen: true,
            appSettingStateProvider: widget.appSettingStateProvider,
            error: widget.kdsProvider.itemsError,
          );
        },
      ),
    );
  }
}
