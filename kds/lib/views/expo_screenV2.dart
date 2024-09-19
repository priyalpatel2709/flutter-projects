import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/groupedorder_model.dart';
import '../providers/items_details_provider.dart';
import 'widgets/itemcartV2.dart';

class ExpoScreenV2 extends StatelessWidget {
  const ExpoScreenV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<KDSItemsProvider>(
      builder: (context, kdsProvider, child) => _ExpoScreenContent(
        kdsProvider: kdsProvider,
      ),
    );
  }
}

class _ExpoScreenContent extends StatefulWidget {
  final KDSItemsProvider kdsProvider;

  const _ExpoScreenContent({Key? key, required this.kdsProvider})
      : super(key: key);

  @override
  _ExpoScreenContentState createState() => _ExpoScreenContentState();
}

class _ExpoScreenContentState extends State<_ExpoScreenContent> {
  String _activeFilter = 'New';

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.kdsProvider.expoFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expo: $_activeFilter (${_getFilteredOrders().length})',
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
          ),
        ),
        backgroundColor: Colors.amber,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _setFilter(value);
              widget.kdsProvider.changeExpoFilter(value);
            },
            itemBuilder: _buildFilterMenu,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if the screen is wide enough for a tablet or laptop
          bool isWideScreen = constraints.maxWidth > 800;

          return widget.kdsProvider.itemsError != ''
              ? Center(child: Text(widget.kdsProvider.itemsError))
              : Padding(
                  padding: EdgeInsets.all(_getPadding(context)),
                  child: ListView.builder(
                    itemCount: _getFilteredOrders().length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isWideScreen
                            ? 12.0
                            : 8.0, // Responsive item spacing
                      ),
                      child: ItemCartV2(
                        items: _getFilteredOrders()[index],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  void _setFilter(String filter) {
    setState(() => _activeFilter = filter);
  }

  List<PopupMenuItem<String>> _buildFilterMenu(BuildContext context) {
    final filterOptions = [
      ('New', 'New'),
      ('all', 'All'),
      ('In Progress', 'In Progress'),
      ('Done', 'Done'),
      ('Cancelled', 'Cancelled'),
      // Add the new filter option
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
      // Use a map to store unique items
      final uniqueItems = <String, OrderItemV2>{};

      // Filter out duplicate items more efficiently
      for (var item in order.items) {
        uniqueItems.putIfAbsent('${item.itemId}_${item.itemName}', () => item);
      }

      // Create a new GroupedOrder with unique items
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
      );
    }).where((order) {
      // Use a more concise switch expression
      return switch (_activeFilter) {
        'In Progress' =>
          order.items.any((item) => item.isInprogress || item.isDone),
        'Done' => order.items.every((item) => item.isDone),
        'Cancelled' => order.items.every((item) => item.isCancel),
        'New' => order.items.every((item) => !item.isDone),
        _ => true
      };
    }).toList();
  }

  double _getTitleFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 28.0; // Laptop
    } else if (width >= 800) {
      return 24.0; // Tablet
    } else {
      return 20.0; // Phone
    }
  }

  double _getPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 24.0; // Laptop
    } else if (width >= 800) {
      return 16.0; // Tablet
    } else {
      return 8.0; // Phone
    }
  }
}
