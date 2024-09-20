import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/groupedorder_model.dart';
import '../../utils/utils.dart';
import 'itemcartV2.dart';

class FilteredOrdersList extends StatelessWidget {
  final List<GroupedOrder>
      filteredOrders; // Replace dynamic with the actual type of your orders
  final int selectedKdsId;
  // final double fontSize;
  // final double padding;
  final bool isHorizontal;
  final bool isComplete;

  const FilteredOrdersList({
    Key? key,
    required this.filteredOrders,
    required this.selectedKdsId,
    // required this.fontSize,
    // required this.padding,
    required this.isHorizontal,
    this.isComplete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // Ensure this is a Column or Row
      children: [
        // Any other widgets you want to add above the Expanded widget can go here.
        Expanded(
          child: isHorizontal
              ? ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (_, index) => ItemCartV2(
                    items: filteredOrders[index],
                    selectedKdsId: selectedKdsId,
                    fontSize: Utils.getTitleFontSize(context),
                    padding: Utils.getPadding(context),
                    isComplete: isComplete,
                  ),
                )
              : MasonryGridView.count(
                  crossAxisCount: Utils.getCrossAxisCount(context),
                  shrinkWrap: true,
                  controller: ScrollController(),
                  itemCount: filteredOrders.length,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (_, index) => Padding(
                    padding: EdgeInsets.symmetric(
                      vertical:
                          Utils.getCrossAxisCount(context) > 1 ? 16.0 : 8.0,
                    ),
                    child: ItemCartV2(
                      items: filteredOrders[index],
                      selectedKdsId: selectedKdsId,
                      fontSize: Utils.getTitleFontSize(context),
                      padding: Utils.getPadding(context),
                      isComplete: isComplete,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
