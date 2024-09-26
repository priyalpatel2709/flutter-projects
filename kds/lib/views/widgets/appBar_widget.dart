import 'package:flutter/material.dart';

import '../../constant/constants.dart';
import '../../providers/appsettings_provider.dart';
import '../pages/settings_screen.dart';

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

  void showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: appSettingStateProvider.fontSize,
              fontWeight: FontWeight.bold,
            ),
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
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
          fit: BoxFit.contain,
        ),
      ),
      // leadingWidth: 80,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: KdsConst.onMainColor,
          ),
          onPressed: () => showSettingsDialog(context),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
