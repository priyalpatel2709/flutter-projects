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
  final KDSItemsProvider _kdsProvider = KDSItemsProvider();
  String _activeFilter = 'isInprogress'; // Default filter

  @override
  void initState() {
    super.initState();
    _kdsProvider.startFetching(timerInterval: 10, storeId: 1);
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
                title: Text(
                    _activeFilter == 'isInprogress' ? 'In Progress' : 'Expo'),
                centerTitle: true,
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (String filter) {
                      setState(() {
                        _activeFilter = ((_activeFilter == filter)
                            ? null
                            : filter)!; // Deselect if clicked again
                      });
                    },
                    icon: const Icon(Icons
                        .filter_list), // Display a filter icon in the AppBar
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'isQueue',
                          child: Text('Queue'),
                        ),
                        const PopupMenuItem(
                          value: 'isInprogress',
                          child: Text('In Progress'),
                        ),
                        const PopupMenuItem(
                          value: 'isDone',
                          child: Text('Done'),
                        ),
                        const PopupMenuItem(
                          value: 'isCancel',
                          child: Text('Cancel'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
              body: _buildLayoutBasedOnSize(
                  constraints, kdsProvider, orderItemStateProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton(String label, String filterType) {
    return ElevatedButton(
      onPressed: () => setState(() {
        _activeFilter = ((_activeFilter == filterType)
            ? null
            : filterType)!; // Deselect if clicked again
      }),
      style: ElevatedButton.styleFrom(
          backgroundColor:
              _activeFilter == filterType ? Colors.blue : Colors.grey),
      child: Text(label, style: const TextStyle(color: Colors.black)),
    );
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
    List<ItemsDetails> filteredItems = _kdsProvider.filterItems(
      isQueue: _activeFilter == 'isQueue' ? true : null,
      isInprogress: _activeFilter == 'isInprogress' ? true : null,
      isDone: _activeFilter == 'isDone' ? true : null,
      isCancel: _activeFilter == 'isCancel' ? true : null,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        try {
          return ItemCart(
            items: filteredItems,
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
