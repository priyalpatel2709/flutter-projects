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
  String _activeFilter = 'In Progress';

  @override
  void initState() {
    super.initState();
    widget.kdsProvider.startFetching(timerInterval: 10, storeId: 1);

    // Set the default selected station to the first station if available
    if (widget.kdsProvider.stations.isNotEmpty) {
      selectedKdsId = widget.kdsProvider.stations.first.kdsId;
      widget.kdsProvider.updateFilters(kdsId: selectedKdsId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Station $_activeFilter',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width > 600
                ? 24
                : 20, // Responsive title font size
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _setFilter,
            itemBuilder: _buildFilterMenu,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if the screen is wide enough for a tablet or laptop
          bool isWideScreen = constraints.maxWidth > 600;

          return Padding(
            padding:
                EdgeInsets.all(isWideScreen ? 16.0 : 8.0), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStationSelector(),
                SizedBox(height: 10), // Space between dropdown and list
                Expanded(
                  child: ListView.builder(
                    itemCount: _getFilteredOrders().length,
                    itemBuilder: (_, index) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            isWideScreen ? 8.0 : 4.0, // Responsive item spacing
                      ),
                      child: ItemCartV2(items: _getFilteredOrders()[index]),
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

  List<GroupedOrder> _getFilteredOrders() {
    return widget.kdsProvider.groupedItems.where((order) {
      if (selectedKdsId != null && order.kdsId != selectedKdsId) return false;

      return switch (_activeFilter) {
        'In Progress' => order.items.any((item) => item.isInprogress) &&
            !order.items.every((item) => item.isDone),
        'Done' => order.items.every((item) => item.isDone),
        'Cancel' => order.items.any((item) => item.isCancel),
        'In Queue' => order.items.any((item) => item.isQueue),
        _ => true,
      };
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
    return ['In Progress', 'Done', 'Cancel', 'In Queue']
        .map((filter) =>
            PopupMenuItem<String>(value: filter, child: Text(filter)))
        .toList();
  }
}
