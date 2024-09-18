import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/groupedorder_model.dart';
import '../providers/items_details_provider.dart';
import 'widgets/itemcartV2.dart';

class StationScreenV2 extends StatelessWidget {
  const StationScreenV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<KDSItemsProvider>(
      builder: (context, kdsProvider, _) =>
          _StationScreenContent(kdsProvider: kdsProvider),
    );
  }
}

class _StationScreenContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;
  const _StationScreenContent({Key? key, required this.kdsProvider})
      : super(key: key);

  @override
  _StationScreenContentState createState() => _StationScreenContentState();
}

class _StationScreenContentState extends State<_StationScreenContent> {
  int? selectedKdsId;
  String _activeFilter = 'New';

  @override
  void initState() {
    super.initState();

    // Start fetching items
    widget.kdsProvider.startFetching(timerInterval: 10, storeId: 1);

    // Schedule the update of the selected station after the build is complete
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
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Station ($selectedKdsId) : $_activeFilter (${_getFilteredOrders().length})',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600
                ? 24
                : 20, // Responsive title font size
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _setFilter(value);
              widget.kdsProvider.changeStationFilter(value);
            },
            itemBuilder: _buildFilterMenu,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if the screen is wide enough for a tablet or laptop
          bool isWideScreen = constraints.maxWidth > 600;

          return widget.kdsProvider.stationsError != '' ||
                  widget.kdsProvider.itemsError != ''
              ? Center(
                  child: Text(
                      '${widget.kdsProvider.stationsError} \n ${widget.kdsProvider.itemsError}'))
              : Padding(
                  padding: EdgeInsets.all(
                      isWideScreen ? 16.0 : 8.0), // Responsive padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStationSelector(),
                      // Text('selectedKdsId--->${selectedKdsId}'),
                      const SizedBox(
                          height: 10), // Space between dropdown and list
                      Expanded(
                        child: ListView.builder(
                          itemCount: _getFilteredOrders().length,
                          itemBuilder: (_, index) => Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isWideScreen
                                  ? 8.0
                                  : 4.0, // Responsive item spacing
                            ),
                            child: ItemCartV2(
                              items: _getFilteredOrders()[index],
                              selectedKdsId: selectedKdsId,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  // Step 1: Filter by selectedKdsId
  List<GroupedOrder> _filterByKdsId() {
    if (selectedKdsId == null) {
      return [];
    }

    // Filter the groupedItems based on selectedKdsId
    return widget.kdsProvider.groupedItems
        .map((order) {
          // Filter the items that match the selectedKdsId
          final filteredItems =
              order.items.where((item) => item.kdsId == selectedKdsId).toList();

          // Return a new GroupedOrder only if there are items matching the selectedKdsId
          if (filteredItems.isNotEmpty) {
            return GroupedOrder(
              orderId: order.orderId,
              items: filteredItems, // Use only the filtered items
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
              // Add other fields if necessary
            );
          }
          return null; // Return null if no items match
        })
        .where((order) => order != null) // Filter out nulls
        .cast<GroupedOrder>() // Cast to the correct type
        .toList(); // Convert to list
  }

  // Step 2: Apply the active filter to the filtered list
  List<GroupedOrder> _getFilteredOrders() {
    List<GroupedOrder> filteredByKdsId = _filterByKdsId();

    return filteredByKdsId.where((order) {
      switch (_activeFilter) {
        case 'In Progress':
          // Show if any item is in progress or done within the filtered list
          return order.items.any((item) => item.isInprogress || item.isDone);
        case 'Done':
          // Show if all items are done within the filtered list
          return order.items.any((item) => item.isDone);
        case 'Cancel':
          // Show if any item is canceled within the filtered list
          return order.items.any((item) => item.isCancel);
        case 'New':
          // Show if no item is done within the filtered list
          return order.items.every((item) => !item.isDone);
        default:
          // Show all orders in the filtered list
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
      isCancel: _activeFilter == 'Cancel',
      isQueue: _activeFilter == 'In Queue',
      kdsId: selectedKdsId,
    );
  }

  List<PopupMenuEntry<String>> _buildFilterMenu(BuildContext context) {
    return [
      'New',
      'In Progress',
      'Done',
      'Cancel',
    ]
        .map((filter) =>
            PopupMenuItem<String>(value: filter, child: Text(filter)))
        .toList();
  }
}
