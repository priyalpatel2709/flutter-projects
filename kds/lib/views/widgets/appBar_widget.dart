import 'package:flutter/material.dart';

import '../../constant/constants.dart';
import '../../providers/appsettings_provider.dart';
import '../../providers/items_details_provider.dart';
import '../../utils/utils.dart';
import '../settings_screen.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHorizontal;
  final VoidCallback iconOnPress;
  final Function(String) onFilterSelected;
  final AppSettingStateProvider appSettingStateProvider;
  final List<PopupMenuEntry<String>> buildFilterMenu;

  const AppBarWidget({
    Key? key,
    required this.title,
    required this.isHorizontal,
    required this.iconOnPress,
    required this.onFilterSelected,
    // required this.kdsProvider,
    required this.buildFilterMenu,
    required this.appSettingStateProvider,
  }) : super(key: key);

  void showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: SingleChildScrollView(
            child: SettingsScreen(),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
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
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: appSettingStateProvider.fontSize,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            appSettingStateProvider
                .changesHorizontal(!appSettingStateProvider.isHorizontal);
          },
          icon: appSettingStateProvider.isHorizontal
              ? const Icon(Icons.screen_lock_landscape)
              : const Icon(Icons.screen_lock_portrait),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            showSettingsDialog(context); // Call the modal popup
          },
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
