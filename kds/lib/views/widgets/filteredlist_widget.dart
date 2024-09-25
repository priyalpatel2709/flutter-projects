import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/appsettings_provider.dart';
import '../../utils/utils.dart';
import 'itemcart.dart';

class FilteredOrdersList extends StatefulWidget {
  final List<GroupedOrder> filteredOrders;
  final int selectedKdsId;
  final bool isComplete;
  final AppSettingStateProvider appSettingStateProvider;

  const FilteredOrdersList({
    Key? key,
    required this.filteredOrders,
    required this.selectedKdsId,
    this.isComplete = false,
    required this.appSettingStateProvider,
  }) : super(key: key);

  @override
  _FilteredOrdersListState createState() => _FilteredOrdersListState();
}

class _FilteredOrdersListState extends State<FilteredOrdersList> {
  int _currentPage = 0;
  // final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.filteredOrders.length /
            widget.appSettingStateProvider.itemsPerPage)
        .ceil();

    return Column(
      children: [
        SizedBox(width: 20 + widget.appSettingStateProvider.padding),
        _orderTypeFilterBtn(),
        SizedBox(width: 20 + widget.appSettingStateProvider.padding),
        Expanded(
          child: _buildPagedContent(),
        ),
        if (totalPages > 1) _buildPaginationControls(totalPages),
      ],
    );
  }

  Widget _orderTypeFilterBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _orderTypeBtn(
          onPressed: () {
            _selectOrderType(KdsConst.dineIn);
          },
          title: 'Dine In',
          isSelected: widget.appSettingStateProvider.selectedOrderType ==
              KdsConst.dineIn,
        ),
        SizedBox(width: 10 + widget.appSettingStateProvider.padding),
        _orderTypeBtn(
          onPressed: () {
            _selectOrderType(KdsConst.pickup);
          },
          title: 'Delivery -Pick Up',
          isSelected: widget.appSettingStateProvider.selectedOrderType ==
              KdsConst.pickup,
        ),
        SizedBox(width: 10 + widget.appSettingStateProvider.padding),
        _orderTypeBtn(
          onPressed: () {
            _selectOrderType(KdsConst.allFilter);
          },
          title: 'All Orders',
          isSelected: widget.appSettingStateProvider.selectedOrderType ==
              KdsConst.allFilter,
        ),
      ],
    );
  }

  // Method to update the selected order type
  void _selectOrderType(String orderType) {
    widget.appSettingStateProvider.changeSelectedOrderType(orderType);
  }

  Widget _orderTypeBtn({
    required Function() onPressed,
    required String title,
    required bool isSelected,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(),
        backgroundColor: isSelected ? KdsConst.mainColor : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        minimumSize: const Size(50, 30), // Small button size
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? KdsConst.onMainColor : Colors.black,
        ),
      ),
    );
  }

  Widget _buildPagedContent() {
    // Get the range of items to display for the current page
    final startIndex =
        _currentPage * widget.appSettingStateProvider.itemsPerPage;
    final endIndex =
        (_currentPage + 1) * widget.appSettingStateProvider.itemsPerPage >
                widget.filteredOrders.length
            ? widget.filteredOrders.length
            : (_currentPage + 1) * widget.appSettingStateProvider.itemsPerPage;

    final pagedOrders = widget.filteredOrders.sublist(startIndex, endIndex);

    // Build the widget based on the selected view from app settings
    switch (widget.appSettingStateProvider.selectedView) {
      case KdsConst.list:
        return _buildHorizontalList(pagedOrders);
      case KdsConst.grid:
        return _buildMasonryGrid(pagedOrders);
      case KdsConst.fixedGrid:
        return SingleChildScrollView(
            child: _buildAdaptiveGrid(context, pagedOrders));
      default:
        return _buildHorizontalList(pagedOrders);
    }
  }

  Widget _buildHorizontalList(List<GroupedOrder> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (_, index) => _buildItemCartV2(orders[index]),
    );
  }

  Widget _buildMasonryGrid(List<GroupedOrder> orders) {
    return MasonryGridView.count(
      crossAxisCount: widget.appSettingStateProvider.crossAxisCount,
      itemCount: orders.length,
      itemBuilder: (_, index) => _buildItemCartV2(orders[index]),
      mainAxisSpacing: widget.appSettingStateProvider.padding,
      crossAxisSpacing: widget.appSettingStateProvider.padding,
    );
  }

  Widget _buildAdaptiveGrid(BuildContext context, List<GroupedOrder> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = widget.appSettingStateProvider.crossAxisCount;
        final columnWidth = constraints.maxWidth / columnCount;

        List<List<GroupedOrder>> rows = [];
        for (var i = 0; i < orders.length; i += columnCount) {
          rows.add(orders.sublist(
              i,
              i + columnCount > orders.length
                  ? orders.length
                  : i + columnCount));
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: widget.appSettingStateProvider.padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: row.map((order) {
                  return SizedBox(
                    width: columnWidth,
                    child: Padding(
                      padding: EdgeInsets.all(
                          widget.appSettingStateProvider.padding),
                      child: ItemCartV2(
                        items: order,
                        selectedKdsId: widget.selectedKdsId,
                        fontSize: widget.appSettingStateProvider.fontSize,
                        padding: widget.appSettingStateProvider.padding,
                        isComplete: widget.isComplete,
                        selectedView:
                            widget.appSettingStateProvider.selectedView,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildItemCartV2(GroupedOrder order) {
    return ItemCartV2(
      items: order,
      selectedKdsId: widget.selectedKdsId,
      fontSize: widget.appSettingStateProvider.fontSize,
      padding: widget.appSettingStateProvider.padding,
      isComplete: widget.isComplete,
      selectedView: widget.appSettingStateProvider.selectedView,
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text('Page ${_currentPage + 1} of $totalPages'),
        IconButton(
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
