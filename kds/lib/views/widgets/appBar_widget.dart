import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../constant/constants.dart';
import '../../providers/appsettings_provider.dart';
import '../pages/settings_screen.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;
  final String filterName;
  final int orderLength;
  final Function(String) onFilterSelected;
  final AppSettingStateProvider appSettingStateProvider;
  final HubConnectionState hubConnectionState;
  final List<PopupMenuEntry<String>> buildFilterMenu;
  final bool showFilterButton;

  const AppBarWidget({
    Key? key,
    required this.screenName,
    required this.filterName,
    required this.onFilterSelected,
    required this.buildFilterMenu,
    required this.appSettingStateProvider,
    required this.orderLength,
    required this.hubConnectionState,
    this.showFilterButton = true,
  }) : super(key: key);

  void navigateToSettingPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: KdsConst.mainColor,
        elevation: 0,
        toolbarHeight: 100,
        leadingWidth: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/images/honest-logo.png',
          height: appSettingStateProvider.appBarLogoSize,
          fit: BoxFit.contain,
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        // Expanded(
        //   flex: 1,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text(
        //         appSettingStateProvider.selectedOrderType,
        //         style: TextStyle(
        //           color: KdsConst.black,
        //           fontWeight: FontWeight.bold,
        //           fontSize: appSettingStateProvider.fontSize,
        //         ),
        //       ),
        //       const SizedBox(height: 4),
        //       Text(
        //         screenName,
        //         style: TextStyle(
        //           color: KdsConst.black,
        //           fontWeight: FontWeight.w600,
        //           fontSize: appSettingStateProvider.fontSize - 2,
        //         ),
        //       ),
        //       const SizedBox(height: 4),
        //       Row(
        //         children: [
        //           Text(
        //             '$filterName - ',
        //             style: TextStyle(
        //               color: KdsConst.black,
        //               fontWeight: FontWeight.w500,
        //               fontSize: appSettingStateProvider.fontSize - 2,
        //             ),
        //           ),
        //           Text(
        //             orderLength.toString(),
        //             style: TextStyle(
        //               color: KdsConst.black,
        //               fontWeight: FontWeight.bold,
        //               fontSize: appSettingStateProvider.fontSize - 4,
        //             ),
        //           ),
        //         ],
        //       )
        //     ],
        //   ),
        // ),
        // Expanded(
        //   flex: 2,
        //   child: Center(
        //     child: Image.asset(
        //       'assets/images/honest-logo.png',
        //       height: 80,
        //       fit: BoxFit.contain,
        //     ),
        //   ),
        // ),
        // Expanded(
        //   flex: 1,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       IconButton(
        //         icon: const Icon(Icons.settings, color: KdsConst.black),
        //         onPressed: () => navigateToSettingPage(context),
        //         tooltip: 'Settings',
        //       ),
        //       PopupMenuButton<String>(
        //         color: KdsConst.white,
        //         icon:
        //             const Icon(Icons.filter_list_alt, color: KdsConst.black),
        //         tooltip: 'Filter',
        //         onSelected: onFilterSelected,
        //         itemBuilder: (context) => buildFilterMenu,
        //       ),
        //     ],
        //   ),
        // ),
        //   ],
        // ),
        actions: [
          Text('$hubConnectionState'),
          IconButton(
            icon: const Icon(Icons.settings, color: KdsConst.black),
            onPressed: () => navigateToSettingPage(context),
            tooltip: 'Settings',
          ),
          showFilterButton
              ? PopupMenuButton<String>(
                  color: KdsConst.white,
                  icon:
                      const Icon(Icons.filter_list_alt, color: KdsConst.black),
                  tooltip: 'Filter',
                  onSelected: onFilterSelected,
                  itemBuilder: (context) => buildFilterMenu,
                )
              : const SizedBox.shrink(),
        ]);
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
