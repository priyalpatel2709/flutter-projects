import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/iItems_details_model.dart';
import '../providers/items_details_provider.dart';
import '../providers/order_item_state_provider.dart';
import 'widgets/itemcart.dart';

class ExpoScreen extends StatefulWidget {
  const ExpoScreen({super.key});

  @override
  _ExpoScreenState createState() => _ExpoScreenState();
}

class _ExpoScreenState extends State<ExpoScreen> {
  late KDSItemsProvider _kdsProvider;
  FilterType _activeFilter = FilterType.isInProgress;

  @override
  void initState() {
    super.initState();
    _kdsProvider = KDSItemsProvider();
    _kdsProvider.startFetching(timerInterval: 10, storeId: 1);

    // Apply default filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kdsProvider.updateFilters(isInProgress: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<KDSItemsProvider, OrderItemStateProvider>(
      builder: (context, kdsProvider, orderItemStateProvider, child) {
        if (kdsProvider.itemsError.isNotEmpty) {
          return Center(
            child: Text(kdsProvider.itemsError),
          );
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.amber,
                title: Text(_getActiveFilterTitle()),
                centerTitle: true,
                actions: [
                  PopupMenuButton<FilterType>(
                    onSelected: (FilterType filter) {
                      _applyFilter(kdsProvider, filter);
                    },
                    icon: const Icon(Icons.filter_list),
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: FilterType.isQueue,
                          child: Text('Queue'),
                        ),
                        const PopupMenuItem(
                          value: FilterType.isInProgress,
                          child: Text('In Progress'),
                        ),
                        const PopupMenuItem(
                          value: FilterType.isDone,
                          child: Text('Done'),
                        ),
                        const PopupMenuItem(
                          value: FilterType.isCancel,
                          child: Text('Cancel'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  kdsProvider.clearFilters();
                },
                child: const Icon(Icons.add),
                backgroundColor: Colors.red,
              ),
              body: _buildLayoutBasedOnSize(
                  constraints, kdsProvider, orderItemStateProvider),
            );
          },
        );
      },
    );
  }

  String _getActiveFilterTitle() {
    switch (_activeFilter) {
      case FilterType.isInProgress:
        return 'In Progress';
      case FilterType.isQueue:
        return 'Queue';
      case FilterType.isDone:
        return 'Done';
      case FilterType.isCancel:
        return 'Cancel';
      default:
        return 'Expo';
    }
  }

  void _applyFilter(KDSItemsProvider kdsProvider, FilterType filter) {
    setState(() {
      _activeFilter = filter;
    });
    kdsProvider.clearFilters();
    switch (filter) {
      case FilterType.isQueue:
        kdsProvider.updateFilters(isQueue: true);
        break;
      case FilterType.isInProgress:
        kdsProvider.updateFilters(isInProgress: true);
        break;
      case FilterType.isDone:
        kdsProvider.updateFilters(isDone: true);
        break;
      case FilterType.isCancel:
        kdsProvider.updateFilters(isCancel: true);
        break;
      case FilterType.orderType:
      // TODO: Handle this case.
      case FilterType.createdOn:
      // TODO: Handle this case.
      case FilterType.kdsId:
      // TODO: Handle this case.
    }
  }

  Widget _buildLayoutBasedOnSize(
      BoxConstraints constraints,
      KDSItemsProvider kdsProvider,
      OrderItemStateProvider orderItemStateProvider) {
    if (constraints.maxWidth >= 1200) {
      return _buildHorizontalLayout(kdsProvider, orderItemStateProvider);
    } else if (constraints.maxWidth >= 600) {
      return _buildGridLayout(kdsProvider, orderItemStateProvider);
    } else {
      return _buildVerticalLayout(kdsProvider, orderItemStateProvider);
    }
  }

  Widget _buildHorizontalLayout(KDSItemsProvider kdsProvider,
      OrderItemStateProvider orderItemStateProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildItemCartWithErrorHandling(
              kdsProvider, orderItemStateProvider),
        ),
      ],
    );
  }

  Widget _buildGridLayout(KDSItemsProvider kdsProvider,
      OrderItemStateProvider orderItemStateProvider) {
    return Column(
      children: [
        Expanded(
          child: _buildItemCartWithErrorHandling(
              kdsProvider, orderItemStateProvider),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(KDSItemsProvider kdsProvider,
      OrderItemStateProvider orderItemStateProvider) {
    return Column(
      children: [
        Expanded(
          child: _buildItemCartWithErrorHandling(
              kdsProvider, orderItemStateProvider),
        ),
      ],
    );
  }

  Widget _buildItemCartWithErrorHandling(KDSItemsProvider kdsProvider,
      OrderItemStateProvider orderItemStateProvider) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        try {
          return ItemCart(
            items: kdsProvider.filteredItems,
            orderItemStateProvider: orderItemStateProvider,
          );
        } catch (e, stackTrace) {
          print('Error rendering ItemCart: $e\n$stackTrace');
          return Center(
            child: Text('Error rendering ItemCart: $e'),
          );
        }
      },
    );
  }
}
