import 'package:flutter/material.dart';

import '../../constant/constants.dart';
import '../../providers/items_details_provider.dart';
import '../../utils/utils.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHorizontal;
  final VoidCallback iconOnPress;
  final Function(String) onFilterSelected;
  // final KDSItemsProvider kdsProvider;
  final List<PopupMenuEntry<String>> buildFilterMenu;

  const AppBarWidget({
    Key? key,
    required this.title,
    required this.isHorizontal,
    required this.iconOnPress,
    required this.onFilterSelected,
    // required this.kdsProvider,
    required this.buildFilterMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KdsConst.mainColor,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: Utils.getTitleFontSize(context),
        ),
      ),
      actions: [
        IconButton(
          onPressed: iconOnPress,
          icon: isHorizontal
              ? const Icon(Icons.screen_lock_landscape)
              : const Icon(Icons.screen_lock_portrait),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            onFilterSelected(value);
          },
          itemBuilder: (context) => buildFilterMenu,
        ),
      ],
    );
  }

  // This defines the preferred size for the widget, which is required for app bars
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
