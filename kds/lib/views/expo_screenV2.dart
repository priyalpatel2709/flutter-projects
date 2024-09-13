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
  String _activeFilter = 'inprogress';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expo: $_activeFilter',
          style: TextStyle(
            fontSize: _getTitleFontSize(context),
          ),
        ),
        backgroundColor: Colors.amber,
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
          bool isWideScreen = constraints.maxWidth > 800;

          return Padding(
            padding: EdgeInsets.all(_getPadding(context)),
            child: ListView.builder(
              itemCount: _getFilteredOrders().length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(
                  vertical:
                      isWideScreen ? 12.0 : 8.0, // Responsive item spacing
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
      ('all', 'All'),
      ('inprogress', 'In Progress'),
      ('done', 'Done'),
      ('cancel', 'Cancelled'),
    ];

    return filterOptions
        .map((option) => PopupMenuItem<String>(
              value: option.$1,
              child: Text(option.$2),
            ))
        .toList();
  }

  List<GroupedOrder> _getFilteredOrders() {
    return widget.kdsProvider.groupedItems.where((order) {
      switch (_activeFilter) {
        case 'inprogress':
          return order.items.any((item) => item.isInprogress) &&
              !order.items.every((item) => item.isDone);
        case 'done':
          return order.items.every((item) => item.isDone);
        case 'cancel':
          return order.items.any((item) => item.isCancel);
        default:
          return true;
      }
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
