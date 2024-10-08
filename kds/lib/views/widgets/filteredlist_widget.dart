import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../constant/constants.dart';
import '../../models/groupedorder_model.dart';
import '../../providers/appsettings_provider.dart';
import 'itemcart.dart';

class FilteredOrdersList extends StatefulWidget {
  final List<GroupedOrder> filteredOrders;
  final int selectedKdsId;
  final bool isExpoScree;
  final AppSettingStateProvider appSettingStateProvider;
  final String error;

  const FilteredOrdersList({
    Key? key,
    required this.filteredOrders,
    required this.selectedKdsId,
    this.isExpoScree = false,
    required this.appSettingStateProvider,
    required this.error,
  }) : super(key: key);

  @override
  _FilteredOrdersListState createState() => _FilteredOrdersListState();
}

class _FilteredOrdersListState extends State<FilteredOrdersList> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final totalPages = (widget.filteredOrders.length /
            widget.appSettingStateProvider.itemsPerPage)
        .ceil();

    return widget.error == ''
        ? Column(
            children: [
              Expanded(
                child: _buildPagedContent(),
              ),
              if (totalPages > 1 &&
                  widget.appSettingStateProvider.showPagination)
                _buildPaginationControls(totalPages),
            ],
          )
        : Center(
            child: Text(
              widget.error,
              style: TextStyle(
                  color: KdsConst.red,
                  fontSize: widget.appSettingStateProvider.fontSize),
            ),
          );
  }

  Widget _buildPagedContent() {
    final startIndex =
        _currentPage * widget.appSettingStateProvider.itemsPerPage;
    final endIndex =
        (_currentPage + 1) * widget.appSettingStateProvider.itemsPerPage;
    final pagedOrders = widget.appSettingStateProvider.showPagination
        ? widget.filteredOrders.sublist(
            startIndex,
            endIndex > widget.filteredOrders.length
                ? widget.filteredOrders.length
                : endIndex,
          )
        : widget.filteredOrders;

    switch (widget.appSettingStateProvider.selectedView) {
      case KdsConst.list:
        return _buildHorizontalList(pagedOrders);
      case KdsConst.grid:
        return _buildMasonryGrid(pagedOrders);
      case KdsConst.fixedGrid:
        return _buildFixedGrid(pagedOrders);
      default:
        return _buildHorizontalList(pagedOrders);
    }
  }

  Widget _buildHorizontalList(List<GroupedOrder> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (_, index) => _buildItemCart(orders[index]),
    );
  }

  Widget _buildMasonryGrid(List<GroupedOrder> orders) {
    return MasonryGridView.count(
      crossAxisCount: widget.appSettingStateProvider.crossAxisCount,
      itemCount: orders.length,
      itemBuilder: (_, index) => _buildItemCart(orders[index]),
      mainAxisSpacing: widget.appSettingStateProvider.padding,
      crossAxisSpacing: widget.appSettingStateProvider.padding,
    );
  }

  Widget _buildFixedGrid(List<GroupedOrder> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = widget.appSettingStateProvider.crossAxisCount;
        final columnWidth = constraints.maxWidth / columnCount;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(
              (orders.length / columnCount).ceil(),
              (rowIndex) {
                final start = rowIndex * columnCount;
                final end = (start + columnCount).clamp(0, orders.length);
                final rowOrders = orders.sublist(start, end);

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: widget.appSettingStateProvider.padding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: rowOrders.map((order) {
                      return SizedBox(
                        width: columnWidth,
                        child: Padding(
                          padding: EdgeInsets.all(
                              widget.appSettingStateProvider.padding),
                          child: _buildItemCart(order),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemCart(GroupedOrder order) {
    return ItemCart(
      items: order,
      selectedKdsId: widget.selectedKdsId,
      fontSize: widget.appSettingStateProvider.fontSize,
      padding: widget.appSettingStateProvider.padding,
      isExpoScreen: widget.isExpoScree,
      selectedView: widget.appSettingStateProvider.selectedView,
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          icon: const Icon(Icons.arrow_back),
        ),
        Text('Page ${_currentPage + 1} of $totalPages'),
        IconButton(
          onPressed: _currentPage < totalPages - 1
              ? () => setState(() => _currentPage++)
              : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  void _selectOrderType(String orderType) {
    widget.appSettingStateProvider.changeSelectedOrderType(orderType);
  }
}
