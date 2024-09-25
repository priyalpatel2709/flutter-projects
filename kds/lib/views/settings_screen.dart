import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constant/constants.dart';
import '../providers/appsettings_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appSettingStateProvider =
        Provider.of<AppSettingStateProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Size Slider
            Text(
              'Font Size: ${appSettingStateProvider.fontSize.toStringAsFixed(1)}',
              style: TextStyle(fontSize: appSettingStateProvider.fontSize),
            ),
            Slider(
              value: appSettingStateProvider.fontSize,
              min: 10.0,
              max: 30.0,
              onChanged: (value) {
                appSettingStateProvider.changeFontSize(value);
              },
            ),
            SizedBox(height: 8 + appSettingStateProvider.padding),

            // Padding Slider
            Text(
              'Padding: ${appSettingStateProvider.padding.toStringAsFixed(1)}',
              style: TextStyle(fontSize: appSettingStateProvider.fontSize),
            ),
            Slider(
              value: appSettingStateProvider.padding,
              min: 0.0,
              max: 20.0,
              onChanged: (value) {
                appSettingStateProvider.changePadding(value);
              },
            ),
            SizedBox(height: 8 + appSettingStateProvider.padding),

            // Cross Axis Count Slider
            Text(
              'Grid Columns: ${appSettingStateProvider.crossAxisCount}',
              style: TextStyle(fontSize: appSettingStateProvider.fontSize),
            ),
            Slider(
              value: appSettingStateProvider.crossAxisCount.toDouble(),
              min: 1.0,
              max: 8,
              divisions: 7,
              onChanged: (value) {
                appSettingStateProvider.changeCrossAxisCount(value.toInt());
              },
            ),
            Text(
              'Items Per Page: ${appSettingStateProvider.itemsPerPage}',
              style: TextStyle(fontSize: appSettingStateProvider.fontSize),
            ),
            Slider(
              value: appSettingStateProvider.itemsPerPage.toDouble(),
              min: 4,
              max: 8,
              divisions: 4,
              onChanged: (value) {
                appSettingStateProvider.changeItemsPerPage(value.toInt());
              },
            ),
            SizedBox(height: 8 + appSettingStateProvider.padding),

            // View Selection Radio Options
            Text(
              'Please Select View:',
              style: TextStyle(fontSize: appSettingStateProvider.fontSize),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Radio<String>(
                    value: KdsConst.grid,
                    groupValue: appSettingStateProvider.selectedView,
                    onChanged: (value) {
                      appSettingStateProvider.changeView(value!);
                    },
                  ),
                  title: Text(
                    KdsConst.grid,
                    style:
                        TextStyle(fontSize: appSettingStateProvider.fontSize),
                  ),
                ),
                ListTile(
                  leading: Radio<String>(
                    value: KdsConst.fixedGrid,
                    groupValue: appSettingStateProvider.selectedView,
                    onChanged: (value) {
                      appSettingStateProvider.changeView(value!);
                    },
                  ),
                  title: Text(
                    KdsConst.fixedGrid,
                    style:
                        TextStyle(fontSize: appSettingStateProvider.fontSize),
                  ),
                ),
                ListTile(
                  leading: Radio<String>(
                    value: KdsConst.list,
                    groupValue: appSettingStateProvider.selectedView,
                    onChanged: (value) {
                      appSettingStateProvider.changeView(value!);
                    },
                  ),
                  title: Text(
                    KdsConst.list,
                    style:
                        TextStyle(fontSize: appSettingStateProvider.fontSize),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
