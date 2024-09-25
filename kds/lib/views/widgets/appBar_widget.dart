import 'package:flutter/material.dart';

import '../../constant/constants.dart';
import '../../providers/appsettings_provider.dart';
import '../../providers/items_details_provider.dart';
import '../../utils/utils.dart';
import '../settings_screen.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  final Function(String) onFilterSelected;
  final AppSettingStateProvider appSettingStateProvider;
  final List<PopupMenuEntry<String>> buildFilterMenu;

  const AppBarWidget({
    Key? key,
    required this.title,
    required this.onFilterSelected,
    required this.buildFilterMenu,
    required this.appSettingStateProvider,
  }) : super(key: key);

  void showSettingsDialog(BuildContext context, double fontSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Settings',
            style: TextStyle(
                fontSize: appSettingStateProvider.fontSize,
                fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SettingsScreen(),
          ),
          actions: [
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(fontSize: appSettingStateProvider.fontSize),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full-height modal
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // For keyboard
          ),
          child: SettingsScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KdsConst.mainColor,
      title: Text(
        title,
        style: TextStyle(
          color: KdsConst.onMainColor,
          fontWeight: FontWeight.bold,
          fontSize: appSettingStateProvider.fontSize,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/images/honest-logo.png',
          fit: BoxFit.fill,
        ),
      ),
      leadingWidth: 100,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: KdsConst.onMainColor,
          ),
          onPressed: () => showSettingsDialog(context,
              appSettingStateProvider.fontSize), // Call the modal popup
        ),
        PopupMenuButton<String>(
          color: KdsConst.onMainColor,
          iconColor: KdsConst.onMainColor,
          icon: const Icon(Icons.filter_list_alt),
          tooltip: 'Filter',
          onSelected: onFilterSelected,
          itemBuilder: (context) => buildFilterMenu,
        ),
      ],
    );
  }

  // This defines the preferred size for the widget, which is required for app bars
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
