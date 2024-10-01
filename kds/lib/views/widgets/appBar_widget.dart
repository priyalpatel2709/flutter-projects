import 'package:flutter/material.dart';
import '../../constant/constants.dart';
import '../../providers/appsettings_provider.dart';
import '../pages/settings_screen.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;
  final String filterName;
  final int orderLength;
  final Function(String) onFilterSelected;
  final AppSettingStateProvider appSettingStateProvider;
  final List<PopupMenuEntry<String>> buildFilterMenu;

  const AppBarWidget({
    Key? key,
    required this.screenName,
    required this.filterName,
    required this.onFilterSelected,
    required this.buildFilterMenu,
    required this.appSettingStateProvider,
    required this.orderLength,
  }) : super(key: key);

  void navigateToSettingPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KdsConst.yellow_newDesign,
      elevation: 0,
      toolbarHeight: 100,
      leadingWidth: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  appSettingStateProvider.selectedOrderType,
                  style: TextStyle(
                    color: KdsConst.black,
                    fontWeight: FontWeight.bold,
                    fontSize: appSettingStateProvider.fontSize,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  screenName,
                  style: TextStyle(
                    color: KdsConst.black,
                    fontWeight: FontWeight.w600,
                    fontSize: appSettingStateProvider.fontSize - 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$filterName - ',
                      style: TextStyle(
                        color: KdsConst.black,
                        fontWeight: FontWeight.w500,
                        fontSize: appSettingStateProvider.fontSize - 2,
                      ),
                    ),
                    Text(
                      orderLength.toString(),
                      style: TextStyle(
                        color: KdsConst.black,
                        fontWeight: FontWeight.bold,
                        fontSize: appSettingStateProvider.fontSize - 4,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Image.asset(
                'assets/images/honest-logo.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings, color: KdsConst.black),
                  onPressed: () => navigateToSettingPage(context),
                  tooltip: 'Settings',
                ),
                PopupMenuButton<String>(
                  color: KdsConst.onMainColor,
                  icon:
                      const Icon(Icons.filter_list_alt, color: KdsConst.black),
                  tooltip: 'Filter',
                  onSelected: onFilterSelected,
                  itemBuilder: (context) => buildFilterMenu,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
